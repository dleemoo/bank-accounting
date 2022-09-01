# frozen_string_literal: true

class Account
  class TransferAmountToAnotherAccount < Micro::Case
    attributes :source_account_id, :target_account_id, :amount

    def call!
      return Failure(result: input_errors) if input_errors.present?

      result = TransferService.call(input)

      return Success(result: result.value!.attributes) if result.success?

      Failure(result: result.failure.errors.to_h)
    end

    private

    def input_errors
      @input_errors ||= input.map do |key, value|
        [key, ["is missing"]] if value.blank?
      end.select(&:present?).to_h
    end

    def input
      { source_account_id:, target_account_id:, amount: }
    end
  end
end
