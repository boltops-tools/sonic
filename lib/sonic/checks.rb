module Sonic
  module Checks
    def check_cluster_exists!
      cluster = ecs.describe_clusters(clusters: [@cluster]).clusters.first
      unless cluster
        UI.error "The #{@cluster.green} cluster does not exist.  Are you sure you specified the right cluster?"
        exit 1
      end
    end

    def check_service_exists!
      begin
        resp = ecs.describe_services(services: [@service], cluster: @cluster)
      rescue Aws::ECS::Errors::ClusterNotFoundException
        UI.error("Unable to find ECS cluster '#{@cluster}'. Are you sure the cluster exists?")
        UI.say("You can specify the cluster with --cluster or you can specify it as a setting in settings.yml.")
        UI.say("More info about settings available at: http://sonic-screwdriver.cloud/docs/settings")
        exit 1
      end

      service = resp.services.first
      unless service
        UI.error "The #{@service.green} service does not exist in #{@cluster.green} cluster.  Are you sure you specified the right service and cluster?"
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

    def task_arns
      @task_arns ||= ecs.list_tasks(cluster: @cluster, service_name: @service).task_arns
    end

    # Only need one container instance to ssh into so we'll just use the first.
    # Useful to have this in a method for subclasses like Sonic::Exec.
    def first_task
      @first_task ||= ecs.describe_tasks(cluster: @cluster, tasks: [task_arns.first]).tasks.first
    end
  end
end
