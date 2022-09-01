# frozen_string_literal: true

class Account
  class Create
    class Persist < Micro::Case
      attributes :name

      def call!
        Success(result: { account: Account.create!(name: name) })
      rescue ActiveRecord::RecordNotUnique
        errors.add(:name, :taken)
        Failure(:invalid_attributes, result: { errors: errors })
      end
    end
  end
end
