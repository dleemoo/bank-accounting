# frozen_string_literal: true

class Account
  class Create < Micro::Case
    attributes :name

    def call!
      return Failure(result: { name: ["is missing"] }) if name.blank?

      result = AccountFactory.call(name: name)

      return Success(result: { account: result.value! }) if result.success?

      Failure(result: result.failure.errors)
    end
  end
end
