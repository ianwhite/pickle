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
    
    def self.factories
      raise NotImplementedError, "return an array of factory adapter objects"
    end
  
    def create(attrs = {})
      raise NotImplementedError, "create and return an object with the given attributes"
    end
  
    cattr_writer :model_classes
    self.model_classes = nil
    
    def self.model_classes
      # remove abstract, framework, and non-table classes
      @@model_classes ||= ::ActiveRecord::Base.send(:subclasses).reject do |klass|
        klass.abstract_class? || !klass.table_exists? ||
         (defined?(CGI::Session::ActiveRecordStore::Session) && klass == CGI::Session::ActiveRecordStore::Session) ||
         (defined?(::ActiveRecord::SessionStore::Session) && klass == ::ActiveRecord::SessionStore::Session)
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
        @klass.send(:make, @blueprint, attrs)
      end
    end
    
    # factory-girl adapter
    class FactoryGirl < Adapter
      def self.factories
        (::Factory.factories.values rescue []).map {|factory| new(factory)}
      end
      
      def initialize(factory)
        @klass, @name = factory.build_class, factory.factory_name.to_s
      end
    
      def create(attrs = {})
        Factory.create(@name, attrs)
      end
    end
        
    # fallback active record adapter
    class ActiveRecord < Adapter
      def self.factories
        model_classes.map {|klass| new(klass) }
      end

      def initialize(klass)
        @klass, @name = klass, klass.name.underscore.gsub('/','_')
      end

      def create(attrs = {})
        @klass.send(:create!, attrs)
      end
    end
  end
end