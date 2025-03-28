# frozen_string_literal: true

require_relative "lib/metatron/version"

Gem::Specification.new do |spec|
  spec.name          = "metatron"
  spec.version       = Metatron::VERSION
  spec.authors       = ["Jonathan Gnagy"]
  spec.email         = ["jonathan.gnagy@gmail.com"]

  spec.summary       = "So meta"
  spec.homepage      = "https://github.com/jgnagy/metatron"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jgnagy/metatron"
  spec.metadata["changelog_uri"] = "https://github.com/jgnagy/metatron/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { _1.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = "~> 3.1"

  spec.add_dependency "base64"
  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "rack", ">= 2.2.8", "< 4"

  spec.add_development_dependency "bundler",             "~> 2.3"
  spec.add_development_dependency "byebug",              "~> 11"
  spec.add_development_dependency "rack-test",           "~> 2.0"
  spec.add_development_dependency "rake",                "~> 12.3"
  spec.add_development_dependency "rspec",               "~> 3.10"
  spec.add_development_dependency "rubocop",             "~> 1.31"
  spec.add_development_dependency "rubocop-rake",        "~> 0.6"
  spec.add_development_dependency "rubocop-rspec",       "~> 2.11"
  spec.add_development_dependency "simplecov",           "~> 0.21"
  spec.add_development_dependency "simplecov-cobertura", "~> 2.1"
  spec.add_development_dependency "solargraph",          "~> 0.45"
  spec.add_development_dependency "yard",                "~> 0.9"
end
