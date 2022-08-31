# frozen_string_literal: true

module Accounts
  class CreateController < ApplicationController
    def call
      Account::Create.call(input)
        .on_success { |r| respond(r.data[:account], :created) }
        .on_failure { |r| respond(r.data, :unprocessable_entity) }
    end

    private

    def input
      params.permit(:name).to_h
    end
  end
end
