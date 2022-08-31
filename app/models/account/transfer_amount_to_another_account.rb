# frozen_string_literal: true

class Account
  class TransferAmountToAnotherAccount < Micro::Case
    flow ValidateInput, Commit
  end
end
