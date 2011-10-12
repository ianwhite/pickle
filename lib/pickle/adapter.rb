require 'active_support/core_ext'

module Pickle
  # Abstract Factory adapter class, if you have a factory type setup, you
  # can easily create an adaptor to make it work with Pickle.
  #
  # The factory adaptor must have a #factories class method that returns
  # its instances, and each instance must respond to:
  #
  #   #name : identifies the factory by name (default is attr_reader)
  #   #klass : returns the associated model class for this factory (default is attr_reader)
  #   #create(attrs = {}) : returns a newly created object
  class Adapter
    attr_reader :name, :klass

    def create(attrs = {})
      raise NotImplementedError, "create and return an object with the given attributes"
    end

    if respond_to?(:class_attribute)
      class_attribute :model_classes
    else
      cattr_writer :model_classes
    end

    self.model_classes = nil

    # Include this module into your ORM adapter
    # this will register the adapter with pickle and it will be picked up for you
    # To create an adapter you should create an inner constant "PickleAdapter"
    #
    # e.g. ActiveRecord::Base::PickleAdapter
    #
    # @see pickle/adapters/active_record
    # @see pickle/adapters/datamapper
    # @see pickle/adapters/mongoid
    module Base
      def self.included(base)
        adapters << base
      end

      # A collection of registered adapters
      def self.adapters
        @@adapters ||= []
      end
    end

    class << self
      def factories
        raise NotImplementedError, "return an array of factory adapter objects"
      end

      def model_classes
        @@model_classes ||= self::Base.adapters.map{ |a| a.model_classes }.flatten
      end

      # Returns the column names for the given ORM model class.
      def column_names(klass)
        klass.const_get(:PickleAdapter).column_names(klass)
      end

      def get_model(klass, id)
        klass.const_get(:PickleAdapter).get_model(klass, id)
      end

      def find_first_model(klass, conditions)
        klass.const_get(:PickleAdapter).find_first_model(klass, conditions)
      end

      def find_all_models(klass, conditions)
        klass.const_get(:PickleAdapter).find_all_models(klass, conditions)
      end

      def create_model(klass, attributes)
        klass.const_get(:PickleAdapter).create_model(klass, attributes)
      end
    end

    # machinist adapter
    class Machinist < Adapter
      def self.factories
        factories = []
        model_classes.each do |klass|
          if blueprints = klass.instance_variable_get('@blueprints')
            blueprints.keys.each {|blueprint| factories << new(klass, blueprint)}
          end
        end
        factories
      end

      def initialize(klass, blueprint)
        @klass, @blueprint = klass, blueprint
        @name = @klass.name.underscore.gsub('/','_')
        @name = "#{@blueprint}_#{@name}" unless @blueprint == :master
      end

      def create(attrs = {})
        if @klass.respond_to?('make!')
          @klass.send(:make!, @blueprint, attrs)
        else
          @klass.send(:make, @blueprint, attrs)
        end
      end
    end

    # factory-girl adapter
    class FactoryGirl < Adapter
      def self.factories
        if defined? ::FactoryGirl
          factories = []
          ::FactoryGirl.factories.each {|v| factories << new(v)}
          factories
        else
          (::Factory.factories.values rescue []).map {|factory| new(factory)}
        end
      end

      def initialize(factory)
        if defined? ::FactoryGirl
          @klass, @name = factory.build_class, factory.name.to_s
        else
          @klass, @name = factory.build_class, factory.factory_name.to_s
        end
      end

      def create(attrs = {})
        if defined? ::FactoryGirl
          ::FactoryGirl.create(@name, attrs)
        else
          Factory(@name, attrs)
        end
      end

      def build(attrs = {})
        if defined? ::FactoryGirl
          ::FactoryGirl.build(@name, attrs)
        else
          Factory.build(@name, attrs)
        end
      end
    end

    # fabrication adapter
    class Fabrication < Adapter
      def self.factories
        if defined? ::Fabrication
          ::Fabrication::Support.find_definitions if ::Fabrication::Fabricator.schematics.empty?
          ::Fabrication::Fabricator.schematics.collect{|v| new(v)}
        else
          []
        end
      end

      def initialize(factory)
        if defined? ::Fabrication
          @klass, @name = factory[1].klass, factory[0].to_s
        end
      end

      def create(attrs = {})
        if defined? ::Fabrication
          ::Fabrication::Fabricator.generate(@name.to_sym, {
              :save => true
              }, attrs)
        end
      end
    end

    # ORM adapter.  If you have no factory adapter, you can use this adapter to
    # use your orm as 'factory' - ie create objects
    class Orm < Adapter
      def self.factories
        model_classes.map{|k| new(k)}
      end

      def initialize(klass)
        @klass, @name = klass, klass.name.underscore.gsub('/','_')
      end

      def create(attrs = {})
        Pickle::Adapter.create_model(@klass, attrs)
      end
    end
  end
end
