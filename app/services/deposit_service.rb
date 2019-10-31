# frozen_string_literal: true

class DepositService
  include CallInterface

  Schema = Dry::Schema.Params do
    required(:account_id).filled(Types::UUID)
    required(:amount).filled(Types::Params::Decimal) { gt?(0) }
  end

  def call(input)
    params  = yield Schema.call(input)
    account = yield fetch_account(params[:account_id])

    Success(deposit!(account, params[:amount]))
  end

  private

  def fetch_account(account_id)
    Maybe(Account.find_by_id(account_id))
      .or(Error(account_id: ["not found"]))
  end

  def deposit!(account, amount)
    account.transaction do
      Operation.create!(kind: "deposit").tap do |operation|
        Credit.create!(account: account, operation: operation, amount: amount)
      end
    end
  end
end
