# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in metatron.gemspec
gemspec

group :development, :test do
  # Dependency vulnerability scanner; run by the `security` CI job on every PR.
  gem "bundler-audit", "~> 0.9"
end
