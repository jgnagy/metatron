#!/bin/sh

gem install bundler
bundle install --jobs=4
rm -rf pkg/*.gem
bundle exec rake build
