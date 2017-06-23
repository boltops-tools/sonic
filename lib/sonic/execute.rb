module Sonic
  class Execute
    include AwsServices

    def initialize(command, options)
      @command = command
      @options = options
      @filter = @options[:filter].split(',').map{|s| s.strip}
    end

    # aws ssm send-command \
    #   --instance-ids i-030033c20c54bf149 \
    #   --document-name "AWS-RunShellScript" \
    #   --comment "Demo run shell script on Linux Instances" \
    #   --parameters '{"commands":["#!/usr/bin/python","print \"Hello world from python\""]}' \
    #   --query "Command.CommandId"
    def execute
      ssm_options = build_ssm_options
      if @options[:noop]
        UI.noop = true
        command_id = "fake command id"
        success = true # fake it for specs
      else
        instances_count = check_instances
        return unless instances_count > 0

        success = nil
        begin
          resp = ssm.send_command(ssm_options)
          command_id = resp.command.command_id
          success = true
        rescue Aws::SSM::Errors::InvalidInstanceId => e
          ssm_invalid_instance_error_message(e)
        end
      end
      if success
        UI.say "Command sent to AWS SSM. To check the details of the command:"
        display_list_command(command_id)
      end
    end

    def build_ssm_options
      criteria = transform_filter(@filter)
      command = build_command(@command)
      criteria.merge(
        document_name: "AWS-RunShellScript",
        comment: "sonic #{ARGV.join(' ')}",
        parameters: {
          "commands" => command
        }
      )
    end

    #
    # Public: Transform the filter to the ssm send_command equivalent options
    #
    # filter  - CLI filter option. Example: hi-web-prod hi-worker-prod hi-clock-prod i-0f7f833131a51ce35
    #
    # Examples
    #
    #   transform_filter(["hi-web-prod", "hi-worker-prod", "i-006a097bb10643e20"])
    #   # => {
    #      instance_ids: ["i-006a097bb10643e20"],
    #      targets: [{key: "Name", values: "hi-web-prod,hi-worker-prod"}]
    #     }
    #
    # Returns the duplicated String.
    def transform_filter(filter)
      valid = validate_filter(filter)
      unless valid
        UI.error("The filter you provided '#{filter.join(',')}' is not valid.")
        UI.say("The filter must either be all instance ids or just a list of tag names.")
        exit 1
      end

      if filter.detect { |i| instance_id?(i) }
        instance_ids = filter
        {instance_ids: instance_ids}
      else
        tags = filter
        targets = [{
          key: "tag:#{tag_name}",
          values: tags
        }]
        {targets: targets}
      end
    end

    # Either all instance ids are no instance ids is a valid filter
    def validate_filter(filter)
      if filter.detect { |i| instance_id?(i) }
        instance_ids = filter.select { |i| instance_id?(i) }
        instance_ids.size == filter.size
      else
        true
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
        [command.join(" ")]
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
      copy_paste_clipboard(ssm_describe_command)
    end

    def file_path?(command)
      return false unless command.size == 1
      possible_path = command.first
      possible_path.include?("file://")
    end

    def file_path(command)
      path = command.first
      path = path.sub('file://', '')
      path = "#{@options[:project_root]}/#{path}" if @options[:project_root]
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

    def display_list_command(command_id)
      list_command = "aws ssm list-commands --command-id #{command_id}"
      UI.say list_command
      copy_paste_clipboard(list_command)
    end

    def copy_paste_clipboard(command)
      return unless RUBY_PLATFORM =~ /darwin/
      system("echo '#{command}' | pbcopy")
      UI.say "Pro tip: the aws ssm command is already in your copy/paste clipboard."
    end
  end
end
