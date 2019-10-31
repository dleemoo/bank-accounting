# frozen_string_literal: true

module Accounts
  class CreateController < ApplicationController
    def call
      AccountFactory.call(request_params!)
        .fmap { |r| respond(r, :created) }
        .or   { |r| respond(r.errors.to_h, :unprocessable_entity) }
    end
  end
end
