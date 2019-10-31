# frozen_string_literal: true

module Operations
  class BalanceController < ApplicationController
    def call
      BalanceService.call(request_params!)
        .fmap { |r| respond(amount: r) }
        .or   { |r| respond(r.errors.to_h, :unprocessable_entity) }
    end
  end
end
