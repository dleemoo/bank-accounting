# frozen_string_literal: true

require "rails_helper"

RSpec.describe Operations::TransferController, type: :controller do
  let(:account) { Account.create!(name: "my-account") }
  let(:target_account) { Account.create!(name: "target-account") }
  let(:deposit) { DepositService }

  before do
    stub_const "ENV", "AUTH_TOKEN" => "VALID_TOKEN"
    request.headers["Authorization"] = "Bearer VALID_TOKEN"
  end

  describe "POST #call" do
    context "with valid parameters" do
      it "returns http success with balance" do
        deposit.call(account_id: account.id, amount: 100)
        post :call, params: { source_account_id: account.id, target_account_id: target_account.id, amount: 50 }

        expect(response).to have_http_status(:success)
        expect(response.body).to eq(JSON(Operation.order(:created_at).last.as_json))
      end
    end

    context "when something is missing" do
      it "returns http failure with service message" do
        deposit.call(acocunt_id: account.id, amount: 100)
        post :call, params: { source_account_id: account.id, target_account_id: target_account.id, amount: 150 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq(JSON(source_account_id: ["insufficient funds"]))
      end
    end

    context "when input is not valid" do
      it "returns http failure with service message" do
        deposit.call(acocunt_id: account.id, amount: 100)
        post :call, params: { source_account_id: account.id, target_account_id: nil, amount: 150 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq(JSON(target_account_id: ["is missing"]))
      end
    end
  end
end
