module Sonic
class Ssh
  autoload :Ec2Tag, 'sonic/ssh/ec2_tag'
  class IdentifierDetector

    include Ec2Tag
    include AwsServices
    include Checks

    def initialize(cluster, service, identifier, options)
      @cluster = cluster
      @service = service
      @identifier = identifier
      @options = options
    end

    # Returns exactly 1 instance_id or exits the program.
    # The bang check_* methods can exit early.
    def detect!
      instance_id = case detected_type
        when :ecs_container_instance_or_task_arn
          check_cluster_exists! unless @options[:noop]

          find_container_instance(@identifier) ||
          find_task(@identifier)
        when :ecs_service
          check_cluster_exists! unless @options[:noop]
          check_service_exists!
          check_tasks_running!

          find_container_instance(first_task.container_instance_arn)
        when :ec2_tag
          find_ec2_instance
        when :ec2_instance
          @identifier
        end
    end

    # Any of these methods either returns exactly 1 instance_id or exit the program.
    #
    # Returns detected_type
    def detected_type
      # Note order here matters because some checks are slower in performance
      @detected_type ||= if instance_id? # fast
        :ec2_instance
      elsif container_instance_or_task_arn? # fast
        :ecs_container_instance_or_task_arn
      elsif ec2_tag_exists? # slow
        :ec2_tag
      else
        :ecs_service # will be slower with the logic from the calling method
      end
    end

    # takes argument
    def find_container_instance(container_instance_arn)
      response = ecs.describe_container_instances(
                    cluster: @cluster,
                    container_instances: [container_instance_arn])

      container_instance = response.container_instances.first
      return false unless container_instance

      ec2_instance_id = container_instance.ec2_instance_id
    end

    def find_task(task_arn)
      response = ecs.describe_tasks(cluster: @cluster, tasks: [task_arn])

      task = response.tasks.first
      unless task
        puts "Unable to find a #{task_arn.green} container instance or task in the #{@cluster.green} cluster."
        exit 1
      end

      find_container_instance(first_task.container_instance_arn)
    end

    # Examples:
    #
    # Container instance ids:
    # b748e59a-b679-42a7-b713-afb12294935b
    # 9f1dadc7-4f67-41da-abec-ec08810bfbc9
    #
    # Task ids:
    # 222c9e66-780b-4755-8c16-8670988e8011
    # 6358f9c2-b231-4f5b-a59b-15bf19d52a15
    #
    # Container instance and task ids have the same format
    def container_instance_or_task_arn?
      @identifier =~ /.{8}-.{4}-.{4}-.{4}-.{12}/
    end

    # Examples:
    # i-006a097bb10643e20
    def instance_id?
      @identifier =~ /i-.{17}/
    end

  end
end
end
