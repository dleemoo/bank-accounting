# frozen_string_literal: true

class Account
  class TransferAmountToAnotherAccount
    class ValidateInput < Micro::Case
      attributes :source_account_id, :target_account_id, :amount

      def call!
        return Failure(result: input_errors) if input_errors.present?
        return Failure(result: { amount: ["must be greater than 0"] }) if negative_amount?
        return Failure(result: { target_account_id: ["is equal to source_account_id"] }) if same_accounts?
        return Failure(result: { source_account_id: ["is in invalid format"] }) if invalid_account_id?(source_account_id)
        return Failure(result: { source_account_id: ["not found"] }) if source_account.blank?
        return Failure(result: { target_account_id: ["is in invalid format"] }) if invalid_account_id?(target_account_id)
        return Failure(result: { target_account_id: ["not found"] }) if target_account.blank?

        Success(
          result: {
            source_account: source_account,
            target_account: target_account,
            amount: BigDecimal(amount, 6)
          }
        )
      end

      private

      def input_errors
        @input_errors ||= { source_account_id:, target_account_id:, amount: }.map do |key, value|
          [key, ["is missing"]] if value.blank?
        end.select(&:present?).to_h
      end

      def negative_amount?
        !BigDecimal(amount, 6).positive?
      end

      def invalid_account_id?(account_id)
        !String(account_id).match?(/^\h{8}(-\h{4}){3}-\h{12}$/)
      end

      def same_accounts?
        source_account_id == target_account_id
      end

      def source_account
        @source_account ||= Account.find_by_id(source_account_id)
      end

      def target_account
        @target_account ||= Account.find_by_id(target_account_id)
      end
    end
  end
end
