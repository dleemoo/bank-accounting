# frozen_string_literal: true

require "rails_helper"

RSpec.describe CallInterface do
  before do
    stub_const("EchoService", Class.new do
      include CallInterface

      def call(input)
        result = yield validate(input)

        Success(result)
      end

      private

      def validate(input)
        return Error(field: :some_message) if input == "fail"

        Success(input)
      end
    end)
  end

  context "common call interface to class that include this module" do
    it "allows successful return for the module that includes it" do
      result = EchoService.call("test")

      expect(result).to be_success
      expect(result.value!).to eq("test")
      expect(result.failure).to be_nil
    end

    it "allows failure return for for the module that includes it" do
      result = EchoService.call("fail")

      expect(result).to be_failure
      expect(result.failure.errors).to eq(field: :some_message)
      expect { result.value! }
        .to raise_error(Dry::Monads::UnwrapError, /value! was called on Failure/)
    end
  end
end
