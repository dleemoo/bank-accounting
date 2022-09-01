# frozen_string_literal: true

require "rails_helper"

require_relative "../../../lib/middlewares/catch_json_parse_errors"

RSpec.describe Middlewares::CatchJsonParseErrors do
  let(:subject) { described_class.new(fake_app) }
  let(:fake_app) do
    # mimic the rails behaviour since ActionDispatch relies on $!
    lambda do |_|
      JSON.parse("{")
    rescue JSON::ParserError
      raise ActionDispatch::Http::Parameters::ParseError
    end
  end

  it "raises the exception for non JSON content types" do
    expect { subject.call("CONTENT_TYPE" => "text/html") }
      .to raise_error(ActionDispatch::Http::Parameters::ParseError)
  end

  it "returns a rack response with invalid json information" do
    error = { errors: ["Invalid JSON"] }

    expect(subject.call("CONTENT_TYPE" => "application/json; charset=utf-8"))
      .to eq([400, { "Content-Type" => "application/json" }, [error.to_json]])
  end
end
