# frozen_string_literal: true

class Account
  class DepositNewAmount < Micro::Case
    attributes :account_id, :amount

    def call!
      return Failure(result: input_errors) if input_errors.present?

      result = DepositService.call(account_id: account_id, amount: amount)

      return Success(result: result.value!.attributes) if result.success?

      Failure(result: result.failure.errors.to_h)
    end

    private

    def input_errors
      @input_errors ||= { account_id: account_id, amount: amount }.map do |key, value|
        [key, ["is missing"]] if value.blank?
      end.select(&:present?).to_h
    end
  end
end
