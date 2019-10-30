# frozen_string_literal: true

require "rails_helper"

RSpec.describe Operation, type: :model do
  context "with valid parameters" do
    it "creates new operation with success" do
      expect { Operation.create(kind: "transfer") }
        .to change(Operation, :count).by(1)
    end
  end

  context "with invalid parameters" do
    it "raises an exception if the name is missing" do
      expect { Operation.create(kind: nil) }
        .to raise_error(ActiveRecord::NotNullViolation, /null value in column "kind" violates not-null constraint/)
        .and change(Operation, :count).by(0)
    end
  end

  context "account and transactions associations" do
    let!(:source_account)     { Account.create!(name: "source") }
    let!(:target_account)     { Account.create!(name: "target") }
    let!(:operation)          { Operation.create!(kind: "transfer") }
    let!(:debit_transaction)  { Transaction.create!(account: source_account, operation: operation, amount: -10) }
    let!(:credit_transaction) { Transaction.create!(account: target_account, operation: operation, amount: 10) }

    it "identifies at Operation the right associations" do
      expect(operation.source_account).to eq(source_account)
      expect(operation.target_account).to eq(target_account)
      expect(operation.debit.id).to eq(debit_transaction.id)
      expect(operation.credit.id).to eq(credit_transaction.id)
    end
  end
end
