# frozen_string_literal: true

class Account
  class CurrentBalance
    class ValidateInput < Micro::Case
      attributes :account_id

      def call!
        return Failure(result: { account_id: ["is missing"] }) if account_id.blank?
        return Failure(result: { account_id: ["is in invalid format"] }) if invalid_account_id?
        return Failure(result: { account_id: ["not found"] }) if account.blank?

        Success(result: { account: account })
      end

      private

      def invalid_account_id?
        !String(account_id).match?(/^\h{8}(-\h{4}){3}-\h{12}$/)
      end

      def account
        @account ||= Account.find_by_id(account_id)
      end
    end
  end
end
