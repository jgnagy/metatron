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

desc "automatically bump the gem's version"
task :bump, [:type] do |_t, args|
  type = args[:type] || ENV["TYPE"] || "patch"
  current_version = Metatron::VERSION
  new_version = calculate_new_version(type)
  puts "Bumping gem version from #{current_version} to #{new_version}"
  update_version(new_version)
  update_gem_lock
end

task default: %i[spec rubocop yard]

def calculate_new_version(type)
  version = Metatron::VERSION.split(".").map(&:to_i)
  case type
  when "patch"
    version[2] += 1
  when "minor"
    version[1] += 1
    version[2] = 0
  when "major"
    version[0] += 1
    version[1] = 0
    version[2] = 0
  end

  version.join(".")
end

def update_gem_lock
  system("bundle lock --update")
end

def update_version(new_version)
  file = File.read("lib/metatron/version.rb")
  new_contents = file.gsub(/VERSION = "(.+)"/, %(VERSION = "#{new_version}"))
  File.write("lib/metatron/version.rb", new_contents)
end
