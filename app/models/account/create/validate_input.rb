# frozen_string_literal: true

class Account
  class Create
    class ValidateInput < Micro::Case
      attributes :name

      validates :name, presence: true

      def call!
        Success(result: { name: name })
      end
    end
  end
end
