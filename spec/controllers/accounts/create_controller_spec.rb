# frozen_string_literal: true

require "rails_helper"

RSpec.describe Accounts::CreateController, type: :controller do
  before do
    stub_const "ENV", "AUTH_TOKEN" => "VALID_TOKEN"
    request.headers["Authorization"] = "Bearer VALID_TOKEN"
  end

  describe "POST #call" do
    context "with valid parameters" do
      it "returns http success with balance" do
        post :call, params: { name: "My Account" }

        expect(response).to have_http_status(:created)
        expect(response.body).to eq(JSON(Account.order(:created_at).last.as_json))
      end
    end

    context "when something is missing" do
      it "returns http failure with service message" do
        post :call

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq(JSON(name: ["is missing"]))
      end
    end
  end
end
