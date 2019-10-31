# frozen_string_literal: true

require "rails_helper"

RSpec.describe AccountFactory do
  subject(:factory) { described_class }

  context "with valid parameters" do
    it "creates a new Account" do
      result = nil

      expect { result = factory.call(name: "My Account") }
        .to change(Account, :count).by(1)

      expect(result).to be_success
      expect(result.value!.name).to eq("My Account")
    end
  end

  context "with invalid paramaters" do
    it "denies when missing name attribute" do
      result = factory.call(name: "")

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(name: ["must be filled"])
    end

    it "dines duplicated account names" do
      factory.call(name: "My Account")
      result = factory.call(name: "My Account")

      expect(result).to be_failure
      expect(result.failure.errors.to_h).to eq(name: ["already taken"])
    end
  end
end
