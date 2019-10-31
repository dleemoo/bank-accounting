# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def fake
      render json: {}, status: 200
    end
  end

  before { stub_const "ENV", "AUTH_TOKEN" => "VALID_TOKEN" }

  describe "success request" do
    context "when use valid token" do
      before { request.headers["Authorization"] = "Bearer VALID_TOKEN" }

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
  end
end
