require 'fileutils'

module Sonic
  class Docker < Ssh
    def setup
      check_service_exists!
      check_tasks_running!
      create_container_data
      black_hole = " > /dev/null" unless @options[:verbose]
      black_hold = ''
      execute("scp -r #{data_path} #{ssh_host}:#{data_path} #{black_hole}")
      FileUtils.rm_rf(data_path) # clean up locally
      # the docker-exec.sh cleans up after itself and blows away /tmp/sonic
    end

    def exec
      setup
      docker_exec = "/tmp/sonic/bash_scripts/docker-exec.sh"
      kernel_exec("ssh", "-t", ssh_host, "bash #{docker_exec}")
    end

    # I cannot name this run like 'docker run' because run is a keyword in Thor.
    def run
      setup
      docker_run = "/tmp/sonic/bash_scripts/docker-run.sh"
      # args = ["ssh", ssh_host, "bash #{docker_run} #{options[:docker_options]}"].compact
      args = ["ssh", "-t", ssh_host, "bash", docker_run, @options[:docker_command]].compact
      kernel_exec(*args)
    end

    def data_path
      "/tmp/sonic"
    end

    def execute(command)
      puts "Running: #{command}"
      system(command)
    end

    # Data that is needed in order to run a new docker container that mimics the
    # docker container that is already running:
    #   * task_arn
    #   * env_vars
    #   * image
    def create_container_data
      # For container env_vars and image info.
      task_definition_arn = task.task_definition_arn # task is a method in the superclass: Ssh
      response = ecs.describe_task_definition(task_definition: task_definition_arn)
      task_definition = response.to_h[:task_definition]
      container_definition = task_definition[:container_definitions].first # assumes care about the first container definition
      env_file_data = env_file_data(container_definition[:environment])

      sonic_folder = "/tmp/sonic"
      FileUtils.mkdir_p(sonic_folder) unless File.exist?(sonic_folder)
      IO.write("/tmp/sonic/task-arn.txt", task_arns.first)
      IO.write("/tmp/sonic/docker-image.txt", container_definition[:image])
      IO.write("/tmp/sonic/env-file.txt", env_file_data)
      FileUtils.cp_r(bash_scripts, "/tmp/sonic")
    end

    # environment - [{:name=>"AUTH_TOKEN", :value=>"xxx"}, {:name=>"RAILS_LOG_TO_STDOUT", :value=>"1"}]
    #
    # Returns String with a simple form, the docker --env-file format
    #
    #   AUTH_TOKEN=xxx
    #   RAILS_LOG_TO_STDOUT=1
    def env_file_data(environment)
      variables = []
      environment.each do |item|
        variables << "#{item[:name]}=#{item[:value]}"
      end
      variables.join("\n")
    end

    def bash_scripts
      File.expand_path("../../bash_scripts", __FILE__)
    end

  end
end
