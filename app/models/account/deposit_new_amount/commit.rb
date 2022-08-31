# frozen_string_literal: true

class Account
  class DepositNewAmount
    class Commit < Micro::Case
      attributes :account, :amount

      def call!
        Success(result: persist!.attributes)
      end

      private

      def persist!
        account.transaction do
          Operation.create!(kind: "deposit").tap do |operation|
            Transaction.create!(account: account, operation: operation, amount: amount)
          end
        end
      end
    end
  end
end
