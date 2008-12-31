module Pickle
  # Abstract Factory adapter class, if you have a factory type setup, you
  # can easily create an adaptor to make it work with Pickle.
  #
  # The factory adaptor must have a #factories class method that returns 
  # its instances, and each instance must respond to a #name method which
  # identifies the factory by name (default is attr_reader for @name), and a
  # #create method which takes an optional attributes hash,
  # and returns a newly created object
  class Adapter
    attr_reader :name
    
    def self.factories
      raise NotImplementedError, "return an array of factory adapter objects"
    end
  
    def create(attrs = {})
      raise NotImplementedError, "create and return an object with the given attributes"
    end
    
    # by default the models are active_record subclasses, but you can set this to whatever classes you want
    class << self
      attr_writer :model_classes
      
      def model_classes
        @model_classes ||= returning(::ActiveRecord::Base.send(:subclasses)) do |classes|
          defined?(CGI::Session::ActiveRecordStore::Session) && classes.delete(CGI::Session::ActiveRecordStore::Session)
        end
      end
    end
    
    # machinist adapter
    class Machinist < Adapter
      def self.factories
        factories = []
        model_classes.each do |klass|
          factories << new(klass, "make") if klass.instance_variable_get('@blueprint')
          # if there are special make_special methods, add blueprints for them
          klass.methods.select{|m| m =~ /^make_/ && m !~ /_unsaved$/}.each do |method|
            factories << new(klass, method)
          end
        end
        factories
      end
      
      def initialize(klass, method)
        @klass, @method = klass, method
        @name = (@method =~ /make_/ ? "#{@method.sub('make_','')}_" : "") + @klass.name.underscore.gsub('/','_')
      end
      
      def create(attrs = {})
        @klass.send(@method, attrs)
      end
    end
    
    # factory-girl adapter
    class FactoryGirl < Adapter
      def self.factories
        (::Factory.factories.keys rescue []).map {|key| new(key)}
      end
      
      def initialize(key)
        @name = key.to_s
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