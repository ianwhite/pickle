require 'dm-core'

module DataMapper::Resource
  module PickleOrmAdapter
    include Pickle::OrmAdapter

    # Do not consider these to be part of the class list
    def self.except_classes
      @@except_classes ||= []
    end

    # Gets a list of the available models for this adapter
    def self.model_classes
      ::DataMapper::Model.descendants.to_a.select{|k| !except_classes.include?(k.name)}
    end

    # get a list of column names for a given class
    def self.column_names(klass)
      klass.properties.map(&:name)
    end

    # Get an instance by id of the model
    def self.get_model(klass, id)
      klass.get(id)
    end

    # Find the first instance matching conditions
    def self.find_first_model(klass, conditions)
      klass.first(conditions)
    end

    # Find all models matching conditions
    def self.find_all_models(klass, conditions)
      klass.all(conditions)
    end
    
    # Create a model using attributes
    def self.create_model(klass, attributes)
      klass.create(attributes)
    end
  end
end
