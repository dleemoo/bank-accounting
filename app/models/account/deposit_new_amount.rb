# frozen_string_literal: true

class Account
  class DepositNewAmount < Micro::Case
    flow ValidateInput, Commit
  end
end
