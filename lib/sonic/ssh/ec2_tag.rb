require 'tty-prompt'

module Sonic
  # ec2 tag related methods
  module Ssh::Ec2Tag
    def ec2_instances
      return @ec2_instances if @ec2_instances

      filters = [{ name: 'tag-value', values: tags_filter }]
      @ec2_instances = ec2_resource.instances(filters: filters)
    end

    # matches any tag value
    def ec2_tag_exists?
      ec2_instances.count > 0
    end

    # If no instances found
    #   Exit immediately with error message
    # If all instances found have the same tag name
    #   Immediately return the first instance id
    # If multiple tag values
    #   Prompt user to select instance tag value of interest
    def find_ec2_instance
      tag_values = ec2_instances.map{ |i| matched_tag_value(i) }.uniq
      case tag_values.size
      when 0
        UI.error("Unable to find an instance with a one of the tag values: #{@identifier}")
        exit 1
      when 1
        ec2_instances.first.instance_id
      else
        # prompt
        select_instance_type(tag_values).instance_id
      end
    end

    def select_instance_type(tag_values)
      UI.say("Found multiple instance types matching the tag filter: #{@identifier}")
      prompt = TTY::Prompt.new
      tag_value = prompt.select("Select an instance type tag:", tag_values)

      # find the first instance with the tag_value
      instance = ec2_instances.find do |i|
        i.tags.find { |t| t.value == tag_value }
      end
    end

    def matched_tag_value(instance)
      tags = instance.tags
      tag = tags.find {|t| tags_filter.include?(t.value) }
      tag.value
    end

    def tags_filter
      @identifier.split(',') # identifier from CLI could be a comma separated list
    end
  end
end
