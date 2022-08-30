# frozen_string_literal: true

require "rails_helper"

RSpec.describe Account, type: :model do
  context "with valid parameters" do
    it "creates new acount with success" do
      expect { Account.create(name: "My Account") }
        .to change(Account, :count).by(1)
    end
  end

  context "with invalid parameters" do
    it "raises an exception if the name is missing" do
      expect { Account.create(name: nil) }
        .to raise_error(ActiveRecord::NotNullViolation,
                        /null value in column "name" of relation "accounts" violates not-null constraint/)
    end

    it "denies duplicated account names" do
      Account.create!(name: "My Account")

      expect { Account.create(name: "My Account") }
        .to raise_error(ActiveRecord::RecordNotUnique, /duplicate key value violates unique constraint "index_accounts_on_name"/)
    end
  end
end
