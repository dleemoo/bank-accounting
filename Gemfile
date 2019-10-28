# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.5"

# basic gems for the framewrok and api
gem "rails", "6.0.0"
gem "puma", "4.2.1"
gem "rake", "13.0.0"

# postgresql database as datastore
gem "pg", "1.1.4"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "1.4.5", require: false

group :development, :test do
  gem "pry-byebug", "3.7.0"
  gem "pry-rails", "0.3.9"
  gem "rspec-rails", "3.9.0"
  gem "brakeman", "4.7.1"
  gem "rubocop", "0.76.0", require: false
  gem "rubocop-rspec", "1.36.0", require: false
end

group :test do
  gem "simplecov", "0.17.1"
end
