# frozen_string_literal: true

module Middlewares
  # This middleware ensures that only JSON requests are accepted.
  class EnforceJsonRequest
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["CONTENT_TYPE"].to_s.match(%r{application/json})
        @app.call(env)
      else
        [400, { "Content-Type" => "application/json" }, [error.to_json]]
      end
    end

    private

    def error
      {
        header: [
          "This API only accepts JSON requests. " \
          "Ensure that you are using 'application/json' at CONTENT_TYPE header."
        ]
      }
    end
  end
end
