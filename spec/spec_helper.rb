# frozen_string_literal: true

require "simplecov"

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [SimpleCov::Formatter::HTMLFormatter]
)

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/.bundle/"
end

require "metatron"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Integration specs need a live k3d cluster and are run by `script/integration`.
  config.filter_run_excluding :integration unless ENV["RUN_INTEGRATION"] == "1"
end
