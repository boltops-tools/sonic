module Sonic
  class List
    include AwsService

    def initialize(options)
      @options = options
      @filter = @options[:filter] ? @options[:filter].split(',').map{|s| s.strip} : []
    end

    def run
      display(instances)
    end

    def instances
      return [] if @options[:noop]

      filter_options = transform_filter_option(@filter)
      begin
        instances = ec2_resource.instances(filter_options)
        instances.count # force eager loading
      rescue Aws::EC2::Errors::InvalidInstanceIDNotFound => e
        # ERROR: The instance ID 'i-066b140d9479e9682' does not exist
        UI.error(e.message)
        exit 1
      end
      instances
    end

    def display(instances)
      zero_instances = instances.count == 0
      UI.say("No instances found with the filter #{@filter.join('')}") if zero_instances

      if @options[:header] && !zero_instances
        header = ["Instance Id", "Name", "Public IP", "Private IP", "Type"]
        UI.say header.join("\t").colorize(:green)
      end

      instances.each do |i|
        line = [i.instance_id, tag_value(i, "Name"), i.public_ip_address, i.private_ip_address, i.instance_type].join("\t")
        UI.say(line)
      end
    end

    def tag_value(instance, key)
      tag = instance.tags.find { |i| i.key == key }
      tag.value
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
