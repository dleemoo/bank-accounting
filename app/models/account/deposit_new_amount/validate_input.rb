# frozen_string_literal: true

class Account
  class DepositNewAmount
    class ValidateInput < Micro::Case
      attributes :account_id, :amount

      validates :account_id, uuid: true
      validates :amount, numericality: { greater_than: 0 }
      validate  :account_exist?

      def call!
        Success(result: { account: account, amount: amount })
      end

      private

      def account
        @account ||= Account.find_by_id(account_id)
      end

      def account_exist?
        return if errors.key?(:account_id)

        account.present? || errors.add(:account_id, "not found")
      end
    end
  end
end
