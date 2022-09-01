# frozen_string_literal: true

require "rails_helper"

RSpec.describe Account::Create do
  subject(:use_case) { described_class }

  context "with valid parameters" do
    it "creates a new Account" do
      result = nil

      expect { result = use_case.call(name: "My Account") }
        .to change(Account, :count).by(1)

      expect(result).to be_success
      expect(result[:account].name).to eq("My Account")
    end
  end

  context "with invalid paramaters" do
    it "denies when missing name attribute" do
      result = use_case.call(name: "")

      expect(result).to be_failure
      expect(result[:errors].messages).to eq(name: ["can't be blank"])
    end

    it "dines duplicated account names" do
      use_case.call(name: "My Account")
      result = use_case.call(name: "My Account")

      expect(result).to be_failure
      expect(result[:errors].messages).to eq(name: ["has already been taken"])
    end
  end
end
