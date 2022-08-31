# frozen_string_literal: true

require "rails_helper"

RSpec.describe Operations::BalanceController, type: :controller do
  let(:account) { Account.create!(name: "my-account") }

  before do
    stub_const "ENV", "AUTH_TOKEN" => "VALID_TOKEN"
    request.headers["Authorization"] = "Bearer VALID_TOKEN"
  end

  describe "POST #call" do
    context "with valid parameters" do
      it "returns http success with balance" do
        post :call, params: { account_id: account.id }

        expect(response).to have_http_status(:success)
        expect(response.body).to eq(JSON(amount: "0.0"))
      end
    end

    context "when something is missing" do
      it "returns http failure with service message" do
        post :call

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq(JSON(account_id: ["is missing"]))
      end
    end

    context "when the account does not exist" do
      it "returns http failure with service message" do
        post :call, params: { account_id: "5367aaf6-416b-477f-81d6-2cbe02f6f7eb" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq(JSON(account_id: ["not found"]))
      end
    end
  end
end
