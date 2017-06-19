require 'fileutils'

module Sonic
  class Docker < Ssh
    def exec
      call("/tmp/sonic/bash_scripts/docker-exec.sh")
    end

    # I cannot name this run like 'docker run' because run is a keyword in Thor.
    def run
      call("/tmp/sonic/bash_scripts/docker-run.sh")
    end

    def tmp_sonic_path
      "/tmp/sonic"
    end

    def setup
      validate!
      copy_over_container_data
    end

    def validate!
      check_service_exists!
      check_tasks_running!
    end

    # command is an Array
    def execute(*command)
      UI.say "=> #{command.join(' ')}".colorize(:green)
      success = system(*command)
      unless success
        UI.error(command.join(' '))
        exit 1
      end
    end

    def call(script)
      setup

      ssh = build_ssh_command
      args = ssh + ["bash", script]

      kernel_exec(*args)
    end

    def copy_over_container_data
      create_container_data

      host = @bastion ? bastion_host : ssh_host

      # LEVEL 1
      # Always clean up remote /tmp/sonic in case of previous interrupted run.
      # Dont use build_ssh_command because we always want to build only the first level server
      ssh = ["ssh", ssh_options, "-At", host]
      clean = ssh + %w[rm -rf /tmp/sonic] + black_hole
      execute(clean.join(' '))

      # Copy over the data files
      dest = "#{host}:#{tmp_sonic_path}"
      scp = ["scp", ssh_options, "-r", tmp_sonic_path, dest] + black_hole
      execute(scp.join(' ')) # need to use String form for black_hole redirection to work

      # LEVEL 2
      # Need to scp the files over another hop if bastion is involved
      if @bastion
        # Always clean up remote /tmp/sonic in case of previous interrupted run.
        ssh = build_ssh_command
        clean = ssh + %w[rm -rf /tmp/sonic] + black_hole
        execute(clean.join(' '))

        # Dont use build_ssh_command because we want to scp from the first level to the second level server
        ssh = ["ssh", ssh_options, "-At", bastion_host]
        dest = "#{ssh_host}:#{tmp_sonic_path}"
        scp = ["scp"] + ssh_options + ["-r", tmp_sonic_path, dest] + black_hole
        command = ssh + scp
        execute(command.join(' '))
      end
      # Clean up locally now that everything has been successfully copied over remotely.
      FileUtils.rm_rf(tmp_sonic_path)
      # The bash_scripts cleans up after themselves on the servers by and blows away /tmp/sonic.
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

    def black_hole
      @options[:verbose] ? [] : %w[> /dev/null 2>&1]
    end

  end
end
