# frozen_string_literal: true

ENV["RACK_ENV"] ||= "development"

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop) # (moved to dedicated github action job)
YARD::Rake::YardocTask.new

desc "allows running a demo controller"
task :demo do
  system("rackup --host 0.0.0.0 -P #{File.expand_path(".")}/tmp/daemon.pid")
end

desc "run integration specs against a real Metacontroller in a k3d cluster"
task :integration do
  sh File.expand_path("script/integration", __dir__)
end

task default: %i[spec rubocop yard]
