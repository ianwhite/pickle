module Pickle
  # Abstract Factory adapter class, if you have a factory type setup, you
  # can easily create an adaptor to make it work with Pickle.
  #
  # The factory adaptor must have a #factories class method that returns 
  # its instances, and each instance must respond to a #name method which
  # identifies the factory by name (default is attr_reader), and a
  # #create method which takes an optional attributes hash,
  # and returns a newly created object
  class Adapter
    attr_reader :name
    
    def self.factories
      raise "Implement me to return an array, each element of which is suitable as a splat for initializing an instance of this class"
    end
  
    def create(attrs = {})
      raise "Implement me to return an object with the given attributes"
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
        ::Factory.send(@name, attrs)
      end
    end
    
    # simple active record adapter
    class ActiveRecord < Adapter
      def self.factories
        ::ActiveRecord::Base.send(:subclasses).map {|klass| new(klass) }
      end

      def initialize(klass)
        @klass, @name = klass, klass.name.underscore
      end

      def create(attrs = {})
        @klass.send(:create!, attrs)
      end
    end
    
    # machinist adapter
    class Machinist < Adapter
      def self.factories
        returning(Array.new) do |f|
          ::ActiveRecord::Base.send(:subclasses).each do |klass|
            klass.methods.select{|m| m =~ /^make/}.each do |method|
              f << new(klass, method)
            end
          end
        end
      end
      
      def initialize(klass, method)
        @klass, @method = klass, method
        @name = (@method == 'make' ? @klass.name.underscore :  "#{@method.sub('make_','')}_#{@klass.name.underscore}")
      end
      
      def create(attrs = {})
        @klass.send(@method, attrs)
      end
    end
  end
end