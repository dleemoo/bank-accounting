# frozen_string_literal: true

module Operations
  class TransferController < ApplicationController
    def call
      TransferService.call(request_params!)
        .fmap { |r| respond(r) }
        .or   { |r| respond(r.errors.to_h, :unprocessable_entity) }
    end
  end
end
