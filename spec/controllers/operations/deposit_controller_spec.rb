# frozen_string_literal: true

require "rails_helper"

RSpec.describe Operations::DepositController, type: :controller do
  let(:account) { Account.create!(name: "my-account") }

  before do
    stub_const "ENV", "AUTH_TOKEN" => "VALID_TOKEN"
    request.headers["Authorization"] = "Bearer VALID_TOKEN"
  end

  describe "POST #call" do
    context "with valid parameters" do
      it "returns http success with balance" do
        post :call, params: { account_id: account.id, amount: 10 }

        expect(response).to have_http_status(:success)
        expect(response.body).to eq(JSON(Operation.order(:created_at).last.as_json))
      end
    end

    context "when something is missing" do
      it "returns http failure with service message" do
        post :call

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq(JSON(account_id: ["is missing"], amount: ["is missing"]))
      end
    end
  end
end
