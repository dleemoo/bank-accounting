# frozen_string_literal: true

require "rails_helper"

RSpec.describe Account::DepositNewAmount do
  subject(:use_case) { described_class }
  let(:account) { Account.create!(name: "acc") }

  context "with valid parameters" do
    it "makes the deposit to account" do
      result = nil

      expect { result = use_case.call(account_id: account.id, amount: 10) }
        .to change(Transaction, :count).by(1)

      expect(result).to be_success

      operation = Operation.find(result.value["id"])

      expect(operation.kind).to eq("deposit")

      expect(operation.credit.amount).to eq(10)
      expect(operation.target_account).to eq(account)

      expect(operation.debt).to be_nil
      expect(operation.source_account).to be_nil
    end
  end

  context "with invalid paramaters" do
    it "does not allows negative deposits" do
      result = nil

      expect { result = use_case.call(account_id: account.id, amount: -10) }
        .not_to change(Transaction, :count)

      expect(result).to be_failure
      expect(result.value).to eq(amount: ["must be greater than 0"])
    end

    it "denies deposit to inexistent account" do
      result = nil

      expect { result = use_case.call(account_id: SecureRandom.uuid, amount: 10) }
        .not_to change(Transaction, :count)

      expect(result).to be_failure
      expect(result.value).to eq(account_id: ["not found"])
    end

    it "denies deposit to invalid account id" do
      result = nil

      expect { result = use_case.call(account_id: "abc", amount: 10) }
        .not_to change(Transaction, :count)

      expect(result).to be_failure
      expect(result.value).to eq(account_id: ["is in invalid format"])
    end
  end
end
