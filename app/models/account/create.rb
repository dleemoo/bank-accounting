# frozen_string_literal: true

class Account
  class Create < Micro::Case
    flow ValidateInput, Persist
  end
end
