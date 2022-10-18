#!/bin/sh

gem install bundler -v '~> 2.3'
bundle install
rm -rf pkg/*.gem
bundle exec rake build
