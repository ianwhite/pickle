module Pickle
  class Adapter
    # ORM adapter.  If you have no factory framework, you can use this adapter to
    # use your orm as 'factory' - ie create objects
    class Orm < Adapter
      def self.adapters
        Pickle::OrmAdapter.model_classes.map{|k| new(k)}
      end

      def initialize(klass)
        @klass, @name = klass, klass.name.underscore.gsub('/','_')
      end

      def make(attrs = {})
        model_class.const_get(:PickleOrmAdapter).create_model(model_class, attrs)
      end
    end
  end
end