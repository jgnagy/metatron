#!/bin/sh

gem install bundler
bundle install --jobs=4
gem build ./metatron.gemspec
bundle exec rake
