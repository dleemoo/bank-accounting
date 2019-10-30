# frozen_string_literal: true

require "rails_helper"

RSpec.describe Operation, type: :model do
  context "with valid parameters" do
    it "creates new operation with success" do
      expect { Operation.create(kind: "transfer") }
        .to change(Operation, :count).by(1)
    end
  end

  context "with invalid parameters" do
    it "raises an exception if the name is missing" do
      expect { Operation.create(kind: nil) }
        .to raise_error(ActiveRecord::NotNullViolation, /null value in column "kind" violates not-null constraint/)
        .and change(Operation, :count).by(0)
    end
  end
end
