# typed: false
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
        ObjectSpace.each_object(Class).to_a.select do |klass|
          klass.name && klass.ancestors.include?(Mongoid::Document)
        end
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
        if defined? ::Mongoid::Criteria
          klass.where(conditions).first
        else
          klass.first(:conditions => conditions)
        end
      end

      # Find all models matching conditions
      def self.find_all_models(klass, conditions)
        if defined? ::Mongoid::Criteria
          klass.where(conditions).to_a
        else
          klass.all(:conditions => conditions)
        end
      end

      # Create a model with given attributes
      def self.create_model(klass, attributes)
        klass.create!(attributes)
      end
    end
  end
end
