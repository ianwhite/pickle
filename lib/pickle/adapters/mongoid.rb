require 'mongoid'

module Mongoid
  module Document
    module PickleAdapter
      include Pickle::Adapter::Base

      # Do not consider these to be part of the class list
      def self.except_classes
        @@except_classes ||= []
      end

      # Gets a list of the available models for this adapter
      def self.model_classes
        ObjectSpace.each_object(Class).to_a.select {|klass| klass.ancestors.include? Mongoid::Document}
      end

      # get a list of column names for a given class
      def self.column_names(klass)
        klass.try(:fields).try(:keys) || []
      end

      # Get an instance by id of the model
      def self.get_model(klass, id)
        klass.find(id)
      end

      # Find the first instance matching conditions
      def self.find_first_model(klass, conditions)
        klass.first(:conditions => conditions)
      end

      # Find all models matching conditions
      def self.find_all_models(klass, conditions)
        klass.all(:conditions => conditions)
      end

      # Create a model with given attributes
      def self.create_model(klass, attributes)
        klass.create!(attributes)
      end
    end
  end
end
