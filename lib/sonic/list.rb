module Sonic
  class List
    include AwsServices

    def initialize(options)
      @options = options
      @filter = @options[:filter] ? @options[:filter].split(',').map{|s| s.strip} : []
    end

    def run
      options = transform_filter_option(@filter)
      puts "options #{options.inspect}"
      if @options[:noop]
        instances = []
      else
        instances = ec2_resource.instances(options)
      end
      display(instances)
    end

    def display(instances)
      if @options[:header]
        UI.say "Instance Id\tPublic IP\tPrivate IP\tType".colorize(:green)
      end

      instances.each do |i|
        line = [i.instance_id, i.public_ip_address, i.private_ip_address, i.instance_type].join("\t")
        UI.say(line)
      end
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
    # Note: method looks close to the Execute#transform_filter method but the criteria
    # structure is slightly different.
    #
    # Returns the duplicated String.
    def transform_filter_option(filter)
      return {} if filter.empty?

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
        criteria = [{
          name: "tag-value",
          values: tags
        }]
        {filters: criteria}
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

    def instance_id?(text)
      text =~ /i-.{17}/
    end
  end
end
