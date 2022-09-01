# frozen_string_literal: true

class Account
  class CurrentBalance
    class Calculate < Micro::Case
      attributes :account

      def call!
        Success(result: { amount: account.transactions.sum(:amount) })
      end
    end
  end
end
