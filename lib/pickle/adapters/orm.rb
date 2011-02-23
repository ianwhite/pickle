module Pickle
  class Adapter
    # ORM adapter.  If you have no factory framework, you can use this adapter to
    # use your orm as 'factory' - ie create objects
    class Orm < Adapter
      def self.adapters
        OrmAdapter.model_classes.map{|k| new(k)}
      end

      def initialize(model_class)
        @model_class, @name = model_class, model_class.name.underscore.gsub('/','_')
      end

      def make(attrs)
        create!(attrs)
      end
    end
  end
end