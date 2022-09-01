# frozen_string_literal: true

class Account
  class CurrentBalance < Micro::Case
    flow ValidateInput, Calculate
  end
end
