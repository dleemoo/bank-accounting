# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# basic gems for the framewrok and api
gem "rails", "6.0.5.1"
gem "psych", "< 4"
gem "puma", "5.6.5"
gem "rake", "13.0.6"

# postgresql database as datastore
gem "pg", "1.4.3"

# u-case
gem "u-case", "4.5.1", require: "u-case/with_activemodel_validation"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "1.13.0", require: false

group :development, :test do
  gem "pry", "0.14.1"
  gem "pry-rails", "0.3.9"
  gem "rspec-rails", "5.1.2"
  gem "brakeman", "5.3.1"
  gem "rubocop", "1.35.1", require: false
end

group :test do
  gem "simplecov", "0.21.2"
end
