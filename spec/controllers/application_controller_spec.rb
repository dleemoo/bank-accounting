# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def fake
      params.permit(:a, :b)

      render json: {}, status: 200
    end
  end

  before do
    stub_const "ENV", "AUTH_TOKEN" => "VALID_TOKEN"
    request.headers["Authorization"] = "Bearer VALID_TOKEN"
  end

  describe "success request" do
    context "when use valid token" do
      it "responds with the successful status" do
        routes.draw { get "fake" => "anonymous#fake" }
        get :fake

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "invalid requests" do
    context "when use invalid token" do
      before { request.headers["Authorization"] = "Bearer INVALID_TOKEN" }

      it "responds with the unauthorized information" do
        routes.draw { get "fake" => "anonymous#fake" }
        get :fake

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq("HTTP Token: Access denied.\n")
      end
    end

    context "when unpermitted parameter present" do
      it "responds with ..." do
        routes.draw { get "fake" => "anonymous#fake" }
        get :fake, params: { a: 10, b: 20, c: 30, d: 40 }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON(response.body)).to eq("error" => "Invalid parameters", "params" => %w[c d])
      end
    end
  end
end
