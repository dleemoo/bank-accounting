# frozen_string_literal: true

module CallInterface
  def self.included(base)
    base.class_eval do
      extend  ClassMethods
      include Dry::Monads[:result]
      include Dry::Monads[:maybe]
      include Dry::Monads::Do.for(:call)
      include InstanceMethods
    end
  end

  module ClassMethods
    def call(input)
      new.call(input)
    end
  end

  module InstanceMethods
    # The method that returns Error(some: "description") are compatible with
    # Dry::Schema failure. This is a syntax sugar to make safe use the chain
    # `.failure.errors.to_h` with a schema validation failure or with some
    # other bussines logic error that use this method.
    #
    # rubocop:disable Naming/MethodName
    def Error(input)
      Failure(
        Class.new(Dry::Struct) do
          attribute :errors, Types::Hash
        end.new(errors: input)
      )
    end
    # rubocop:enable Naming/MethodName
  end
end
