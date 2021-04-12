require 'yaml'
require 'active_support/core_ext/hash'

module Sonic
  class Execute
    include AwsService

    def initialize(command, options)
      @command = command
      @options = options
      @tags = @options[:tags]
      @instance_ids = @options[:instance_ids]
    end

    # aws ssm send-command \
    #   --instance-ids i-030033c20c54bf149 \
    #   --document-name "AWS-RunShellScript" \
    #   --comment "Demo run shell script on Linux Instances" \
    #   --parameters '{"commands":["#!/usr/bin/python","print \"Hello world from python\""]}' \
    #   --query "Command.CommandId"
    def execute
      check_filter_options!
      ssm_options = build_ssm_options
      if @options[:noop]
        UI.noop = true
        command_id = "fake command id for noop mode"
        success = true # fake it for specs
      else
        instances_count = check_instances
        return unless instances_count > 0

        success = nil
        puts "Sending command to SSM with options:"
        puts YAML.dump(ssm_options.deep_stringify_keys)
        puts
        begin
          resp = send_command(ssm_options)

          command_id = resp.command.command_id
          success = true
        rescue Aws::SSM::Errors::InvalidInstanceId => e
          ssm_invalid_instance_error_message(e)
        end
      end

      return unless success

      # IF COMMAND IS ONLY ON A SINGLE INSTANCE THEN WILL DISPLAY A BUNCH OF
      # INFO ON THE INSTANCE. IF ITS A LOT OF INSTANCES, THEN SHOW A SUMMARY
      # OF COMMANDS THAT WILL LEAD TO THE OUTPUT OF EACH INSTANCE.
      UI.say "Command sent to AWS SSM. To check the details of the command:"
      display_ssm_commands(command_id, ssm_options)
      puts
      return if @options[:noop]
      status = wait(command_id)
      display_ssm_output(command_id)
      display_console_url(command_id)

      if status == "Success"
        puts "Command successful: #{status}".color(:green)
        exit_status(0)
      else
        puts "Command unsuccessful: #{status}".color(:red)
        exit_status(1)
      end
    end

    def exit_status(code)
      exit(code) if cli?

      if code == 0
        true
      else
        raise "Error running command"
      end
    end

    def cli?
      $0.include?('sonic')
    end

    def wait(command_id)
      ongoing_states = ["Pending", "InProgress", "Delayed"]

      print "Waiting for ssm command to finish..."
      resp = ssm.list_commands(command_id: command_id)
      status = resp["commands"].first["status"]
      while ongoing_states.include?(status)
        resp = ssm.list_commands(command_id: command_id)
        status = resp["commands"].first["status"]
        sleep 1
        print '.'
      end
      puts "\nCommand finished."
      puts
      status
    end

    def display_ssm_output(command_id)
      resp = ssm.list_command_invocations(command_id: command_id)
      command_invocations = resp.command_invocations
      command_invocation = command_invocations.first
      unless command_invocation
        puts "WARN: No instances found that matches the --tags or --instance-ids option".color(:yellow)
        return false # instances_found
      end
      instance_id = command_invocation.instance_id

      if command_invocations.size > 1
        puts "Multiple instance targets. Total targets: #{command_invocations.size}. Only displaying output for #{instance_id}."
      else
        puts "Displaying output for #{instance_id}."
      end

      resp = ssm.get_command_invocation(
        command_id: command_id, instance_id: instance_id
      )
      puts "Command status: #{colorized_status(resp["status"])}"
      ssm_output(resp, "output")
      ssm_output(resp, "error")
      puts
      true # instances_found
    end

    def display_console_url(command_id)
      region = `aws configure get region`.strip rescue 'us-east-1'
      console_url = "https://#{region}.console.aws.amazon.com/systems-manager/run-command/#{command_id}"
      puts "To see the more output details visit:"
      puts "  #{console_url}"
      puts
      copy_paste_clipboard(console_url, "Pro tip: the console url is already in your copy/paste clipboard.")
    end

    def colorized_status(status)
      case status
      when "Success"
        status.color(:green)
      when "Failed"
        status.color(:red)
      else
        status
      end
    end

    # type: output or error
    def ssm_output(resp, type)
      content_key = "standard_#{type}_content"
      s3_key = "standard_#{type}_url"

      content = resp[content_key]
      return if content.empty?

      puts "Command standard #{type}:"
      # "https://s3.amazonaws.com/infra-prod/ssm/commands/sonic/0a4f4bef-8f63-4235-8b30-ae296477261a/i-0b2e6e187a3f9ada9/awsrunPowerShellScript/0.awsrunPowerShellScript/stderr">
      if content.include?("--output truncated--") && !resp[s3_key].empty?
        s3_url = resp[s3_key]
        info = s3_url.sub('https://s3.amazonaws.com/', '').split('/')
        bucket = info[0]
        key = info[1..-1].join('/')
        resp = s3.get_object(bucket: bucket, key: key)
        data = resp.body.read
        puts data

        path = "/tmp/sonic-output.txt"
        puts "------"
        puts "Output also written to #{path}"
        IO.write(path, data)
      else
        puts content
      end

      # puts "#{s3_key}: #{resp[s3_key]}"
    end

    def send_command(options)
      retries = 0

      begin
        resp = ssm.send_command(options)
      rescue Aws::SSM::Errors::UnsupportedPlatformType
        retries += 1
        # toggle AWS-RunShellScript / AWS-RunPowerShellScript
        options[:document_name] =
          options[:document_name] == "AWS-RunShellScript" ?
          "AWS-RunPowerShellScript" : "AWS-RunShellScript"

        puts "#{$!}"
        puts "Retrying with document_name #{options[:document_name]}"
        puts "Retries: #{retries}"

        retries <= 1 ? retry : raise
      end

      resp
    end

    def build_ssm_options
      criteria = transform_filter_option
      command = build_command(@command)
      options = criteria.merge(
        document_name: "AWS-RunShellScript", # default
        comment: "sonic #{ARGV.join(' ')}"[0..99], # comment has a max of 100 chars
        parameters: { "commands" => command },
        # Default CloudWatchLog settings. Can be overwritten with settings.yml send_command
        # IMPORTANT: make sure the EC2 instance the command runs on has access to write to CloudWatch Logs.
        cloud_watch_output_config: {
          # cloud_watch_log_group_name: "ssm", # Defaults to /aws/ssm/AWS-RunShellScript (aws/ssm/SystemsManagerDocumentName https://amzn.to/38TKVse)
          cloud_watch_output_enabled: true,
        },
      )
      settings_options = settings["send_command"] || {}
      options.merge(settings_options.deep_symbolize_keys)
    end

    def settings
      @settings ||= Setting.new.data
    end

    def check_filter_options!
      return if @tags || @instance_ids
      puts "ERROR: Please provide --tags or --instance-ids option".color(:red)
      exit 1
    end

    #
    # Public: Transform the filter to the ssm send_command equivalent options
    #
    # filter  - CLI filter option. Example: hi-web-prod hi-worker-prod hi-clock-prod i-0f7f833131a51ce35
    #
    # Examples
    #
    #   transform_filter_option
    #   # => {
    #      instance_ids: ["i-006a097bb10643e20"],
    #      targets: [{key: "Name", values: "hi-web-prod,hi-worker-prod"}]
    #     }
    #
    # Returns the duplicated String.
    def transform_filter_option
      if @tags
        list = @tags.split(';')
        targets = list.inject([]) do |final,item|
          tag_name,value_list = item.split('=')
          values = value_list.split(',').map(&:strip)
          # structure expected by ssm send_command
          option = {
            key: "tag:#{tag_name}",
            values: values
          }
          final << option
          final
        end
        {targets: targets}
      else # @instance_ids
        instance_ids = @instance_ids.split(',')
        {instance_ids: instance_ids}
      end
    end

    def build_command(command)
      if file_path?(command)
        path = file_path(command)
        if File.exist?(path)
          IO.readlines(path).map {|s| s.strip}
        else
          UI.error("File #{path} could not be found. Are you sure it exist?")
          exit 1
        end
      else
        # The script is being feed inline so just join the command together into one script.
        # Still keep in an array form because that's how ssn.send_command works with AWS-RunShellScript
        # usually reads the command.
        command.is_a?(Array) ? command : [command]
      end
    end

    # e = Aws::SSM::Errors::InvalidInstanceId
    def ssm_invalid_instance_error_message(e)
      # e.message is an empty string so not very helpful
      ssm_describe_command = 'aws ssm describe-instance-information --output text --query "InstanceInformationList[*]"'
      message = <<-EOS
One of the instance ids: #{@filter.join(",")} is invalid according to SSM.
This might be because the SSM agent on the instance has not yet checked in.
You can use the following command to check registered instances to SSM.
#{ssm_describe_command}
      EOS
      UI.warn(message)
      copy_paste_clipboard(ssm_describe_command, "Pro tip: ssm describe-instance-information already in your copy/paste clipboard.")
    end

    def file_path?(command)
      return false unless command.size == 1
      possible_path = command.first
      possible_path.include?("file://")
    end

    def file_path(command)
      path = command.first
      path = path.sub('file://', '')
      path = "#{Sonic.root}/#{path}"
      path
    end

    # Counts the number of instances found using the filter and displays a helpful
    # message to the user if 0 found.
    def check_instances
      return if @options[:zero_warn] == false

      # The list options is a superset of the execute options so we can pass
      # it right through
      instances = List.new(@options).instances
      if instances.count == 0
        message = <<-EOL
Unable to find any instances with filter #{@filter.join(',')}.
  Are you sure you specify the filter with either a EC2 tag or list instance ids?
  If you are using ECS identifiers, they are not supported with this command.
EOL
        UI.warn(message)
      end
      instances.count
    end

    # TODO: make configurable
    def tag_name
      "Name"
    end

    def instance_id?(text)
      # new format is 17 characters long after i-
      # old format is 8 characters long after i-
      text =~ /i-.{17}/ || text =~ /i-.{8}/
    end

    def display_ssm_commands(command_id, ssm_options)
      list_command = "  aws ssm list-commands --command-id #{command_id}"
      UI.say list_command

      return unless ssm_options[:instance_ids]
      ssm_options[:instance_ids].each do |instance_id|
        get_command = "  aws ssm get-command-invocation --command-id #{command_id} --instance-id #{instance_id}"
        UI.say get_command
      end
    end

    def copy_paste_clipboard(command, text)
      return unless RUBY_PLATFORM =~ /darwin/
      system("echo '#{command}' | pbcopy")
      UI.say text
    end
  end
end
