module Pickle
  class Adapter
    # factory-girl adapter
    class FactoryGirl < Adapter
      def self.adapters
        (::Factory.factories.values rescue []).map {|factory| new(factory)}
      end

      def initialize(factory)
        @model_class, @name = factory.build_class, factory.factory_name.to_s
      end

      def make(attrs = {})
        Factory(@model_class, attrs)
      end
    end
  end
end