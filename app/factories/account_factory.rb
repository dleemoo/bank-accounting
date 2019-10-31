# frozen_string_literal: true

class AccountFactory
  include CallInterface

  Schema = Dry::Schema.Params do
    required(:name).filled(:string)
  end

  def call(input)
    params = yield Schema.call(input)

    Success(create_account!(params))
  rescue ActiveRecord::RecordNotUnique
    Error(name: ["already taken"])
  end

  private

  def create_account!(result)
    Account.create!(result.to_h)
  end
end
