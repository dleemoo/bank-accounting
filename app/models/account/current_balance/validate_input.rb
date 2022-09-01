# frozen_string_literal: true

class Account
  class CurrentBalance
    class ValidateInput < Micro::Case
      attributes :account_id

      validates :account_id, uuid: true
      validate  :account_exist?

      def call!
        Success(result: { account: account })
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
