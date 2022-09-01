# frozen_string_literal: true

class Account
  class TransferAmountToAnotherAccount
    class ValidateInput < Micro::Case
      AMOUNT_PRECISION = 16

      attributes :source_account_id, :target_account_id, :amount

      validates :source_account_id, :target_account_id, uuid: true
      validates :amount, numericality: { greater_than: 0 }
      validate  :distinct_accounts?
      validate  :accounts_exist?

      def call!
        Success(
          result: {
            source_account: source_account,
            target_account: target_account,
            amount: BigDecimal(amount, AMOUNT_PRECISION)
          }
        )
      end

      private

      def source_account
        @source_account ||= Account.find_by_id(source_account_id)
      end

      def target_account
        @target_account ||= Account.find_by_id(target_account_id)
      end

      def distinct_accounts?
        return if source_account_id != target_account_id

        errors.add(:target_account_id, "is equal to source_account_id")
      end

      def accounts_exist?
        return if errors.key?(:source_account_id) || errors.key?(:target_account_id)

        source_account || errors.add(:source_account_id, "not found")
        target_account || errors.add(:target_account_id, "not found")
      end
    end
  end
end
