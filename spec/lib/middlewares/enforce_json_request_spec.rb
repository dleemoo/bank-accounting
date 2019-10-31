# frozen_string_literal: true

require "rails_helper"

require_relative "../../../lib/middlewares/enforce_json_request"

RSpec.describe Middlewares::EnforceJsonRequest do
  let(:subject) { described_class.new(fake_app) }
  let(:fake_app) { ->(_) { :success } }

  it "calls the application with valid JSON content type header" do
    expect(subject.call("CONTENT_TYPE" => "application/json; charset=utf-8")).to eq(:success)
  end

  it "returns a rack response with invalid content type information" do
    error = {
      header: [
        "This API only accepts JSON requests. " \
        "Ensure that you are using 'application/json' at CONTENT_TYPE header."
      ]
    }

    expect(subject.call("CONTENT_TYPE" => "text/html"))
      .to eq([400, { "Content-Type" => "application/json" }, [error.to_json]])
  end
end
