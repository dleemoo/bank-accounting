# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative "../lib/middlewares/catch_json_parse_errors"
require_relative "../lib/middlewares/enforce_json_request"

module BankAccounting
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # config logger
    config.log_formatter = ::Logger::Formatter.new
    if ENV["DISABLE_STDOUT_LOG"] != "true" && !Rails.env.test?
      logger = ActiveSupport::Logger.new($stdout)
      config.logger = ActiveSupport::TaggedLogging.new(logger)
    end

    # rails do not serve any public file
    config.public_file_server.enabled = false

    # use uuids for primary and foreign keys
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.orm :active_record, foreign_key_type: :uuid
    end

    # use sql schema to allows use of the database features
    config.active_record.schema_format = :sql

    # raise exception when unpermitted parameters are present
    config.action_controller.action_on_unpermitted_parameters = :raise

    # Add a middleware to ensure that we only accept JSON requests
    config.middleware.use Middlewares::EnforceJsonRequest

    # Add custom middleware to show a better message for malformed JSON.
    # This also make production and developmet to have the same behavior, since
    # that by default in production rails ends up generating a error 500.
    config.middleware.use Middlewares::CatchJsonParseErrors
  end
end
