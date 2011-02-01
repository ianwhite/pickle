require 'sequel'

class Sequel::Model
  module PickleAdapter
    include Pickle::Adapter::Base

    # Do not consider these to be part of the class list
    def self.except_classes
      @@except_classes ||= []
    end

    # Gets a list of the available models for this adapter
    def self.model_classes
      ::Sequel::Model.descendants.to_a.select{|k| !except_classes.include?(k.name)}
    end

    # get a list of column names for a given class
    def self.column_names(klass)
      klass.columns
    end

    # Get an instance by id of the model
    def self.get_model(klass, id)
      klass[id]
    end

    # Find the first instance matching conditions
    def self.find_first_model(klass, conditions)
      conditions.symbolize_keys!
      klass.where(conditions).first
    end

    # Find all models matching conditions
    def self.find_all_models(klass, conditions)
      conditions.symbolize_keys!
      klass.where(conditions).all
    end

    # Create a model using attributes
    def self.create_model(klass, attributes)
      attributes.symbolize_keys!
      klass.create(attributes)
    end
  end
end
