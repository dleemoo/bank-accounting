# frozen_string_literal: true

class Account
  class CurrentBalance < Micro::Case
    attributes :account_id

    def call!
      return Failure(result: { account_id: ["is missing"] }) if account_id.blank?

      result = BalanceService.call(account_id: account_id)

      return Success(result: { amount: result.value! }) if result.success?

      Failure(result: result.failure.errors.to_h)
    end
  end
end
