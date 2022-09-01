# frozen_string_literal: true

class TransferService
  include CallInterface
  InsufficientFunds = Class.new(RuntimeError)

  Schema = Dry::Schema.Params do
    required(:source_account_id).filled(Types::UUID)
    required(:target_account_id).filled(Types::UUID)
    required(:amount).filled(Types::Params::Decimal) { gt?(0) }
  end

  def call(input)
    params = yield Schema.call(input)
    source = yield fetch_account(params, :source_account_id)
    target = yield fetch_account(params, :target_account_id)

    return same_account_error if source.id == target.id

    Success(transfer!(source, target, params[:amount]))
  rescue InsufficientFunds
    Error(source_account_id: ["insufficient funds"])
  end

  private

  def fetch_account(params, key)
    Maybe(Account.find_by_id(params[key]))
      .or(Error(key => ["not found"]))
  end

  def transfer!(source, target, amount)
    source.with_lock do
      balance = BalanceService.call(account_id: source.id)
      raise InsufficientFunds if balance.value! < amount

      Operation.create!(kind: "transfer").tap do |operation|
        Transaction.create!(account: source, operation: operation, amount: -amount)
        Transaction.create!(account: target, operation: operation, amount: amount)
      end
    end
  end

  def same_account_error
    Error(target_account_id: ["is equal to source_account_id"])
  end
end
