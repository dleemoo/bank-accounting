# frozen_string_literal: true

module Operations
  class TransferController < ApplicationController
    def call
      Account::TransferAmountToAnotherAccount.call(input)
        .on_success { |r| respond(r.data) }
        .on_failure { |r| respond(r.data, :unprocessable_entity) }
    end

    private

    def input
      params.permit(:source_account_id, :target_account_id, :amount).to_h
    end
  end
end
