# frozen_string_literal: true

class Account
  class Create
    class Persist < Micro::Case
      attributes :name

      def call!
        Success(result: { account: Account.create!(name: name) })
      rescue ActiveRecord::RecordNotUnique
        Failure(result: { name: ["already taken"] })
      end
    end
  end
end
