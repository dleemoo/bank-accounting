# frozen_string_literal: true

module Middlewares
  # This middleware catches errors from received JSON payload and respond with
  # bad request including a standard error message.
  class CatchJsonParseErrors
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue ActionDispatch::Http::Parameters::ParseError => e
      raise e unless env["CONTENT_TYPE"].to_s.match(%r{application/json})

      [400, { "Content-Type" => "application/json" }, [error.to_json]]
    end

    private

    def error
      { body: ["Invalid JSON"] }
    end
  end
end
