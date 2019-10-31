# frozen_string_literal: true

require "rails_helper"

RSpec.describe BalanceService do
  subject(:service) { described_class }
  let(:account) { Account.create!(name: "acc") }
  let(:deposit) { DepositService }

  context "with valid parameters" do
    context "when account has no value" do
      it "returns zero" do
        result = service.call(account_id: account.id)

        expect(result).to be_success
        expect(result.value!).to eq(0)
      end
    end

    context "when account has some income values" do
      it "returns the sum of these values" do
        deposit.call(account_id: account.id, amount: 100.39)
        deposit.call(account_id: account.id, amount: 100.74)

        result = service.call(account_id: account.id)

        expect(result).to be_success
        expect(result.value!).to eq(201.13)
      end
    end
  end

  context "with invalid paramaters" do
    it "denies balance to inexistent account" do
      result = service.call(account_id: SecureRandom.uuid, amount: 10)

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(account_id: ["not found"])
    end

    it "denies balance to invalid account id" do
      result = service.call(account_id: "abc")

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(account_id: ["is in invalid format"])
    end
  end
end
