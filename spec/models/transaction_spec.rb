# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transaction, type: :model do
  let(:account)   { Account.create!(name: "account") }
  let(:operation) { Operation.create!(kind: "deposit") }

  context "with valid parameters" do
    it "creates new transaction with success" do
      params = { account: account, operation: operation, amount: 10 }

      expect { Transaction.create(params) }
        .to change(Transaction, :count).by(1)
    end

    it "creates new transaction with negative amount" do
      params = { account: account, operation: operation, amount: -10 }

      expect { Transaction.create(params) }
        .to change(Transaction, :count).by(1)
    end
  end

  context "with invalid parameters" do
    it "raises an exception if the account is missing" do
      params = { operation: operation, amount: 10 }

      expect { Transaction.create!(params) }
        .to raise_error(ActiveRecord::RecordInvalid, /Account must exist/)
        .and change(Transaction, :count).by(0)
    end

    it "raises an exception if the operation is missing" do
      params = { account: account, amount: 10 }

      expect { Transaction.create!(params) }
        .to raise_error(ActiveRecord::RecordInvalid, /Operation must exist/)
        .and change(Transaction, :count).by(0)
    end

    it "raises an exception if the amount is missing" do
      params = { operation: operation, account: account }

      expect { Transaction.create(params) }
        .to raise_error(ActiveRecord::NotNullViolation,
                        /null value in column "amount" of relation "transactions" violates not-null constraint/)
        .and change(Transaction, :count).by(0)
    end

    it "raises an exception if the amount is equal to zero" do
      params = { operation: operation, account: account, amount: 0 }

      expect { Transaction.create!(params) }
        .to raise_error(ActiveRecord::StatementInvalid, /violates check constraint "non_zero_amount_on_transactions"/)
        .and change(Transaction, :count).by(0)
    end
  end
end
