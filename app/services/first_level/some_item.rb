module FirstLevel
  module SomeItem
    class << self
      def call
        self::OtherItem
      end
    end
  end
end
