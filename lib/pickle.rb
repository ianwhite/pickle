# Pickle == cucumber + factory
#
# = Usage
#   # in features/steps/_env.rb
#   require 'pickle/steps'
#
# If you need to configure pickle, do it like this
#
#   Pickle::Config.map 'I|me|my', :to => 'user: "me"'
#   require 'pickle/steps'
module Pickle
  module Version
    Major = 0
    Minor = 1
    Tiny  = 1
    
    String = [Major, Minor, Tiny].join('.')
  end
    
  module Config
    class << self
      attr_writer :model_names, :factory_names, :blueprint_names, :names, :mappings
      
      def model_names
        @model_names ||= ActiveRecord::Base.send(:subclasses).map(&:name).map(&:underscore)
      end

      def blueprint_names
        require 'machinist'
        @blueprint_names ||= machinist_make_methods
      rescue LoadError
        @blueprint_names = []
      end
      
      def factory_names
        require 'factory_girl'
        @factory_names ||= Factory.factories.keys.map(&:to_s)
      rescue LoadError
        @factory_names = []
      end

      def names
        @names ||= (model_names | factory_names | blueprint_names)
      end
      
      def mappings
        @mappings ||= []
      end
      
      def map(search, options)
        raise ArgumentError, "Usage: map 'search', :to => 'replace'" unless search.is_a?(String) && options[:to].is_a?(String)
        self.mappings << [search, options[:to]]
      end
    
    protected
      def machinist_make_methods
        returning Array.new do |methods|
          ActiveRecord::Base.send(:subclasses).each do |ar|
            ar.respond_to?(:make) && methods.push(ar.name.underscore)
          end
        end
      end
    end
  end
end