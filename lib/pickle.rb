require 'pickle/adapter'

module Pickle
  module Version
    Major = 0
    Minor = 1
    Tiny  = 1
    
    String = [Major, Minor, Tiny].join('.')
  end
    
  module Config
    class << self
      attr_writer :adapters, :factories, :mappings
      
      def adapters
        @adapters ||= [Adapter::Machinist, Adapter::FactoryGirl, Adapter::ActiveRecord]
      end
      
      def factories
        @factories ||= adapters.inject({}) {|factories, adapter| factories.merge(adapter.factories_hash) }
      end

      def names
        @names ||= factories.keys.sort
      end
      
      def mappings
        @mappings ||= []
      end
      
      def map(search, options)
        raise ArgumentError, "Usage: map 'search', :to => 'replace'" unless search.is_a?(String) && options[:to].is_a?(String)
        self.mappings << [search, options[:to]]
      end
    end
  end
end