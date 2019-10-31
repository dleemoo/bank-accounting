# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  private

  def respond(data, status = :ok)
    render json: data, status: status
  end

  # This method is a syntax sugar to skip the repetition of permit all
  # parameters from params.
  #
  # Whenever this method is called, the caller must assume the responsibility
  # of using parameters in a safe way.
  def request_params!
    params.permit!.to_h
  end

  def authenticate
    authenticate_or_request_with_http_token do |token, _options|
      ActiveSupport::SecurityUtils.secure_compare(
        token, ENV.fetch("AUTH_TOKEN")
      )
    end
  end
end
