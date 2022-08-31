# frozen_string_literal: true

class Account
  class Create
    class ValidateInput < Micro::Case
      attributes :name

      def call!
        return Failure(result: { name: ["is missing"] }) if name.blank?

        Success(result: { name: name })
      end
    end
  end
end
