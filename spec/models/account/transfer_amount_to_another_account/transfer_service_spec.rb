# frozen_string_literal: true

require "rails_helper"

RSpec.describe Account::TransferAmountToAnotherAccount do
  subject(:use_case) { described_class }

  let(:deposit) { DepositService }
  let(:balance) { BalanceService }

  let(:source_account) { Account.create!(name: "source account") }
  let(:target_account) { Account.create!(name: "target account") }

  context "with valid parameters" do
    it "makes the transfer between the accounts" do
      deposit.call(account_id: source_account.id, amount: 100)

      result = nil

      expect { result = use_case.call(source_account_id: source_account.id, target_account_id: target_account.id, amount: 10) }
        .to change(Transaction.where(account_id: source_account), :count).by(1)
        .and change(Transaction.where(account_id: target_account), :count).by(1)

      expect(result).to be_success

      operation = Operation.find(result.value["id"])

      expect(operation.kind).to eq("transfer")

      expect(operation.credit.amount).to eq(10)
      expect(operation.target_account).to eq(target_account)

      expect(operation.debit.amount).to eq(-10)
      expect(operation.source_account).to eq(source_account)

      expect(balance.call(account_id: source_account.id).value!).to eq(90)
      expect(balance.call(account_id: target_account.id).value!).to eq(10)
    end
  end

  context "with insuficient funds in source account" do
    it "denies the transaction" do
      deposit.call(account_id: source_account.id, amount: 100)

      result = nil

      expect { result = use_case.call(source_account_id: source_account.id, target_account_id: target_account.id, amount: 100.01) }
        .to change(Transaction.where(account_id: source_account), :count).by(0)
        .and change(Transaction.where(account_id: target_account), :count).by(0)

      expect(result).to be_failure
      expect(result.value).to eq(source_account_id: ["insufficient funds"])

      expect(balance.call(account_id: source_account.id).value!).to eq(100)
      expect(balance.call(account_id: target_account.id).value!).to eq(0)
    end
  end

  context "with invalid paramaters" do
    it "does not allows negative transfers" do
      result = nil

      expect { result = use_case.call(source_account_id: source_account.id, target_account_id: target_account.id, amount: -10) }
        .to change(Transaction, :count).by(0)
        .and change(Operation, :count).by(0)

      expect(result).to be_failure
      expect(result.value).to eq(amount: ["must be greater than 0"])
    end

    it "does not allow the same account for source and target" do
      result = nil

      expect { result = use_case.call(source_account_id: source_account.id, target_account_id: source_account.id, amount: 10) }
        .to change(Transaction, :count).by(0)
        .and change(Operation, :count).by(0)

      expect(result).to be_failure
      expect(result.value).to eq(target_account_id: ["is equal to source_account_id"])
    end

    it "denies transfers to inexistent source account" do
      result = use_case.call(source_account_id: SecureRandom.uuid, target_account_id: target_account.id, amount: 10)

      expect(result).to be_failure
      expect(result.value).to eq(source_account_id: ["not found"])
    end

    it "denies transfers to inexistent target account" do
      result = use_case.call(source_account_id: source_account.id, target_account_id: SecureRandom.uuid, amount: 10)

      expect(result).to be_failure
      expect(result.value).to eq(target_account_id: ["not found"])
    end

    it "denies transfers to invalid source account" do
      result = use_case.call(source_account_id: "abc", target_account_id: target_account.id, amount: 10)

      expect(result).to be_failure
      expect(result.value).to eq(source_account_id: ["is in invalid format"])
    end

    it "denies transfers to invalid target account" do
      result = use_case.call(source_account_id: source_account.id, target_account_id: "abc", amount: 10)

      expect(result).to be_failure
      expect(result.value).to eq(target_account_id: ["is in invalid format"])
    end
  end
end
