require 'colorize'

module Sonic
  class Ssh
    autoload :IdentifierDetector, 'sonic/ssh/identifier_detector'
    autoload :CliOptions, 'sonic/ssh/cli_options'

    include AwsService
    include CliOptions

    def initialize(identifier, options)
      @options = options

      @user, @identifier = extract_user!(identifier) # extracts/strips user from identifier
      # While --user option is supported at the class level, don't expose at the CLI level
      # to encourage users to use user@host notation.
      @user ||= options[:user] || settings["bastion"]["user"]

      @service = @identifier # always set service even though it's not always used as the identifier
      map = settings["ecs_service_cluster_map"]
      @cluster = options[:cluster] || map[@service] || map["default"] || "default"
      @bastion = options[:bastion] || settings["bastion"]["host"]
    end

    def run
      ssh = build_ssh_command
      retry_until_success(*ssh) if @options[:retry]
      kernel_exec(*ssh) # must splat the Array here
    end

    def bastion_host
      return @identifier if @options[:noop] # for specs
      @bastion_host ||= build_bastion_host
    end

    def build_bastion_host
      host = @bastion
      host = "#{@user}@#{host}" unless host.include?('@')
      host
    end

    # used by child Classes
    def ssh_host
      return @identifier if @options[:noop] # for specs
      @ssh_host ||= build_ssh_host
    end

    def build_ssh_host
      return @identifier if ENV['TEST']

      instance_id = detector.detect!
      instance_hostname(instance_id)
    end

    def detector
      @detector ||= Ssh::IdentifierDetector.new(@cluster, @service, @identifier, @options)
    end


    def instance_hostname(ec2_instance_id)
      begin
        resp = ec2.describe_instances(instance_ids: [ec2_instance_id])
      rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => e
        # e.message: The instance ID 'i-027363802c6ff3141' does not exist
        UI.error e.message
        exit 1
      rescue Aws::Errors::NoSuchEndpointError, SocketError
        UI.error "It doesnt look like you have an internet connection. Please double check that you have an internet connection."
        exit 1
      end
      instance = resp.reservations[0].instances[0]
      # struct Aws::EC2::Types::Instance
      # http://docs.aws.amazon.com/sdkforruby/api/Aws/EC2/Types/Instance.html
      if @bastion
        instance.private_ip_address
      else
        instance.public_ip_address
      end
    end

    # Will use Kernel.exec so that the ssh process takes over this ruby process.
    def kernel_exec(*args)
      # append the optional command that can be provided to the ssh command
      full_command = args + @options[:command]
      puts "=> #{full_command.join(' ')}".colorize(:green)
      # https://ruby-doc.org/core-2.3.1/Kernel.html#method-i-exec
      # Using 2nd form
      Kernel.exec(*full_command) unless @options[:noop]
    end

private
    # direct access to settings data
    def settings
      @settings ||= Setting.new.data
    end

    # Returns Array of flags.
    # Example:
    #   ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
    def ssh_options
      keys_option + host_key_check_options
    end

    # By default bypass strict host key checking for convenience.
    # But user can overrride this.
    def host_key_check_options
      if settings["bastion"]["host_key_check"] == true
        []
      else
        # settings["bastion"]["host_key_check"] nil will disable checking also
        # disables host key checking
        %w[-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null]
      end
    end

    # Will prepend the bastion host if required
    # When bastion set
    #   ssh [options] -At [bastion_host] ssh -At [ssh_host]
    #
    # When bastion not set
    #   ssh [options] -At [ssh_host]
    #
    # Builds up ssh command to be used with Kernel.exec. Will look something like this:
    #   ssh -At ec2-user@34.211.223.3 ssh ec2-user@10.10.110.135
    # It is imporant to use an Array for the command so it gets intrepreted as if you are
    # executing it from the shell directly. For example, globs gets expanded with the
    # Array notation but not the String notation.
    #
    # ssh options:
    # -A = Enables forwarding of the authentication agent connection
    # -t = Force pseudo-terminal allocati
    def build_ssh_command
      command = ["ssh", "-t"] + ssh_options
      if @bastion
        # https://en.wikibooks.org/wiki/OpenSSH/Cookbook/Proxies_and_Jump_Hosts
        # -J xxx is -o ProxyJump=xxx
        proxy_jump = ["-J", bastion_host]
        command += proxy_jump
      end
      command += ["-t", "#{@user}@#{ssh_host}"]
    end

    # Private: Extracts and strips the user from the identifier.
    #
    # identifier  - Can be a variety of things: instance_id, ecs service, ecs task, etc.
    #
    # Examples
    #
    #   extract_user!("i-0f7f833131a51ce35")
    #   # => [nil, "i-0f7f833131a51ce35"]
    #
    #   extract_user!("ec2-user@i-0f7f833131a51ce35")
    #   # => ["ec2-user", "i-0f7f833131a51ce35"]
    #
    # Returns the a tuple cotaining the user and identifier
    def extract_user!(identifier)
      md = identifier.match(/(.*)@(.*)/)
      if md
        [md[1], md[2]]
      else
        [nil, identifier]
      end
    end

    def retry_until_success(*command)
      retries = 0
      uptime = command + ['uptime', '2>&1']
      uptime = uptime.join(' ')
      out = `#{uptime}`
      while out !~ /load average/ do
        puts "Can't ssh into the server yet.  Retrying until success." if retries == 0
        print '.'
        retries += 1
        sleep 1
        out = `#{uptime}`
      end
      puts "" if @options[:retry] && retries > 0
    end
  end
end
