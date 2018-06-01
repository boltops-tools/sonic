require "bundler/gem_tasks"
require "rspec/core/rake_task"

task default: :spec

RSpec::Core::RakeTask.new

require_relative "lib/sonic"
require "cli_markdown"
desc "Generates cli reference docs as markdown"
task :docs do
  CliMarkdown::Creator.create_all(cli_class: Sonic::CLI, cli_name: "sonic")
end
