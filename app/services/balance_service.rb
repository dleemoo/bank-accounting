# frozen_string_literal: true

class BalanceService
  include CallInterface

  Schema = Dry::Schema.Params do
    required(:account_id).filled(Types::UUID)
  end

  def call(input)
    params  = yield Schema.call(input)
    account = yield fetch_account(params[:account_id])

    Success(account.transactions.sum(:amount))
  end

  private

  def fetch_account(account_id)
    Maybe(Account.find_by_id(account_id))
      .or(Error(account_id: ["not found"]))
  end
end
