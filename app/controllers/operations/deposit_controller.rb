# frozen_string_literal: true

module Operations
  class DepositController < ApplicationController
    def call
      Account::DepositNewAmount.call(input)
        .on_success { |r| respond(r.data) }
        .on_failure { |r| respond(r.data, :unprocessable_entity) }
    end

    private

    def input
      params.permit(:account_id, :amount).to_h
    end
  end
end
