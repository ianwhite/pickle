module Pickle
  # Include this module into your ORM adapter
  # this will register the adapter with pickle and it will be picked up for you
  # To create an adapter you should create an inner constant "PickleOrmAdapter"
  #
  # e.g. ActiveRecord::Base::PickleOrmAdapter
  #
  # @see pickle/orm_adapters/active_record
  # @see pickle/orm_adapters/datamapper
  # @see pickle/orm_adapters/mongoid
  module OrmAdapter
    class << self
      def included(adapter)
        adapter.extend Contract
        adapters << adapter
      end

      # A collection of registered adapters
      def adapters
        @@adapters ||= []
      end
      
      # all model classes from all registered adapters
      def model_classes
        @@model_classes ||= adapters.map{|a| a.model_classes }.flatten
      end
    end
    
    # override these class methods on your orm adapter 
    module Contract
      # Gets a list of the available models for this adapter
      def model_classes
        raise NotImplementedError, "return a list of available models for this adapter"
      end

      # Get an instance by id of the model
      def get_model(klass, id)
        raise NotSupportedError
      end

      # Find the first instance matching conditions
      def find_first_model(klass, conditions)
        raise NotSupportedError
      end

      # Find all models matching conditions
      def find_all_models(klass, conditions)
        raise NotSupportedError
      end

      # Create a model using attributes
      def create_model(klass, attributes)
        raise NotSupportedError
      end
    end
    
    class NotSupportedError < RuntimeError
      def to_s
        "method not supported by this orm adapter"
      end
    end
    
    # included in Pickle::Adapter
    module AdapterMethods
      def find_first(conditions = {})
        model_class.const_get(:PickleOrmAdapter).find_first_model(model_class, conditions)
      end

      def find_all(conditions = {})
        model_class.const_get(:PickleOrmAdapter).find_all_models(model_class, conditions)
      end

      def get(id)
        model_class.const_get(:PickleOrmAdapter).get_model(model_class, id)
      end
    end
  end
end