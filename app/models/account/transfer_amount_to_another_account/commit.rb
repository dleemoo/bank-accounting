# frozen_string_literal: true

class Account
  class TransferAmountToAnotherAccount
    class Commit < Micro::Case
      attributes :source_account, :target_account, :amount

      def call!
        Success(result: persist!.attributes)
      rescue InsufficientFunds
        errors.add(:source_account_id, "insufficient funds")
        Failure(:invalid_attributes, result: { errors: errors })
      end

      private

      InsufficientFunds = Class.new(RuntimeError)

      def persist!
        source_account.with_lock do
          validate_account_funds!

          Operation.create!(kind: "transfer").tap do |operation|
            Transaction.create!(account: source_account, operation: operation, amount: -amount)
            Transaction.create!(account: target_account, operation: operation, amount: amount)
          end
        end
      end

      def validate_account_funds!
        balance = Account::CurrentBalance.call(account_id: source_account.id)
        raise InsufficientFunds if balance[:amount] < amount
      end
    end
  end
end
