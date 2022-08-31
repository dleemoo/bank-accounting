# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# basic gems for the framewrok and api
gem "rails", "7.0.3.1"
gem "puma", "5.6.5"
gem "rake", "13.0.6"

# postgresql database as datastore
gem "pg", "1.4.3"
# managed and versioned database views
gem "scenic", "1.6.0"

# u-case
gem "u-case", "4.5.1"

# monads to implement railway oriented programming
gem "dry-monads", "1.4.0"

# gems to implement contract validation with types with interfaces
gem "dry-schema", "1.10.2"
gem "dry-types", "1.5.1"
gem "dry-struct", "1.4.0"

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
