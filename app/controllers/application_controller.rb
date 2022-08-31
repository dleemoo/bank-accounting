# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  private

  def respond(data, status = :ok)
    render json: data, status: status
  end

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      ActiveSupport::SecurityUtils.secure_compare(
        token, ENV.fetch("AUTH_TOKEN")
      )
    end
  end
end
