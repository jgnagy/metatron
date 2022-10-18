# frozen_string_literal: true

ENV["RACK_ENV"] ||= "development"

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)
YARD::Rake::YardocTask.new

desc "allows running a demo controller"
task :demo do
  system("rackup --host 0.0.0.0 -P #{File.expand_path(".")}/tmp/daemon.pid")
end

task default: %i[spec rubocop yard]
