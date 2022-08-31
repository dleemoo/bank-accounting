# frozen_string_literal: true

class Account
  class DepositNewAmount
    class ValidateInput < Micro::Case
      attributes :account_id, :amount

      def call!
        return Failure(result: input_errors) if input_errors.present?
        return Failure(result: { amount: ["must be greater than 0"] }) if negative_amount?
        return Failure(result: { account_id: ["is in invalid format"] }) if invalid_account_id?
        return Failure(result: { account_id: ["not found"] }) if account.blank?

        Success(result: { account: account, amount: amount })
      end

      private

      def input_errors
        @input_errors ||= { account_id: account_id, amount: amount }.map do |key, value|
          [key, ["is missing"]] if value.blank?
        end.select(&:present?).to_h
      end

      def negative_amount?
        !BigDecimal(amount, 6).positive?
      end

      def invalid_account_id?
        !String(account_id).match?(/^\h{8}(-\h{4}){3}-\h{12}$/)
      end

      def account
        @account ||= Account.find_by_id(account_id)
      end
    end
  end
end
