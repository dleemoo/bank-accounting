# frozen_string_literal: true

require "rails_helper"

RSpec.describe Credit, type: :model do
  let(:account)   { Account.create!(name: "account") }
  let(:operation) { Operation.create!(kind: "operation") }

  context "given a Transaction with a positive amount" do
    let(:transaction) { Transaction.create!(account: account, operation: operation, amount: 10) }

    it "identifies transaction as a Credit" do
      expect(Credit.find_by(id: transaction.id).id).to eq(transaction.id)
    end
  end

  context "given a Transaction with a negative amount" do
    let(:transaction) { Transaction.create!(account: account, operation: operation, amount: -10) }

    it "does not identifies that as a Credit" do
      expect(Credit.find_by(id: transaction.id)).to be_nil
    end
  end
end
