#!/bin/sh

gem install bundler
bundle install --jobs=4
rm -rf pkg/*.gem
bundle exec rake build
bundle exec gem push pkg/*.gem
