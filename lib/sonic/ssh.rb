require 'colorize'

module Sonic
  class Ssh
    include Defaults
    include AwsServices

    def initialize(identifier, options)
      @options = options
      @identifier = identifier
      @service = @identifier # always set service even though sometimes it is not the identifier
      @cluster = options[:cluster] || default_cluster
      @user = options[:user] || default_user
    end

    def run
      check_cluster_exists! unless @options[:noop]
      kernel_exec("ssh", ssh_host)
    end

    # used by child Classes
    def ssh_host
      return @identifier if @options[:noop] # for specs
      @ssh_host ||= build_ssh_host
    end

    def build_ssh_host
      ec2_instance_id = if instance_id?
                          @identifier
                        elsif container_instance_or_task_arn?
                          find_by_container_instance(@identifier) ||
                          find_by_task(@identifier)
                        else # service name
                          check_service_exists!
                          check_tasks_running!
                          container_instance_arn = task.container_instance_arn
                          find_by_container_instance(container_instance_arn)
                        end
      instance_hostname(ec2_instance_id)
    end

    def find_by_task(task_arn)
      response = ecs.describe_tasks(
                    cluster: @cluster,
                    tasks: [task_arn])
      task = response.tasks.first
      unless task
        puts "Unable to find a #{task_arn.green} container instance or task in the #{@cluster.green} cluster."
        exit 1
      end
      find_by_container_instance(task.container_instance_arn)
    end

    def find_by_container_instance(container_instance_arn)
      response = ecs.describe_container_instances(
                    cluster: @cluster,
                    container_instances: [container_instance_arn])
      container_instance = response.container_instances.first
      unless container_instance
        return false
      end
      ec2_instance_id = container_instance.ec2_instance_id
    end

    def check_cluster_exists!
      cluster = ecs.describe_clusters(clusters: [@cluster]).clusters.first
      unless cluster
        puts "The #{@cluster.green} cluster does not exist.  Are you sure you specified the right cluster?"
        exit 1
      end
    end

    def check_service_exists!
      service = ecs.describe_services(services: [@service], cluster: @cluster).services.first
      unless service
        puts "The #{@service.green} service does not exist in #{@cluster.green} cluster.  Are you sure you specified the right service and cluster?"
        exit 1
      end
    end

    def check_tasks_running!
      if task_arns.empty?
        puts "Unable to find a running task that belongs to the #{@service} service on the #{@cluster} cluster."
        puts "There must be a running task in order for sonic to look up an container instance."
        exit 1
      end
    end

    def instance_hostname(ec2_instance_id)
      instance = ec2.describe_instances(instance_ids: [ec2_instance_id]).reservations[0].instances[0]
      # struct Aws::EC2::Types::Instance
      # http://docs.aws.amazon.com/sdkforruby/api/Aws/EC2/Types/Instance.html
      host = instance.public_dns_name
      "#{@user}@#{host}"
    end

    def task_arns
      @task_arns ||= ecs.list_tasks(cluster: @cluster, service_name: @service).task_arns
    end

    # Only need one container instance to ssh into so we'll just use the first.
    # Useful to have this in a method for subclasses like Sonic::Exec.
    def task
      @task ||= ecs.describe_tasks(cluster: @cluster, tasks: [task_arns.first]).tasks.first
    end


    # Will use Kernel.exec so that the ssh process takes over this ruby process.
    def kernel_exec(*args)
      # append the optional command that can be provided to the ssh command
      full_command = args + @options[:command]
      puts "Running: #{full_command.join(' ')}"
      # https://ruby-doc.org/core-2.3.1/Kernel.html#method-i-exec
      # Using 2nd form
      Kernel.exec(*full_command) unless @options[:noop]
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
