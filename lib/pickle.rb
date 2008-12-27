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
        @model_names ||= Pickle::Adapter::ActiveRecord.factories.map(&:name)
      end

      def blueprint_names
        @blueprint_names ||= Pickle::Adapter::Machinist.factories.map(&:name)
      end
      
      def factory_names
        @factory_names ||= Pickle::Adapter::FactoryGirl.factories.map(&:name)
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
      
      def require_frameworks
        # try and require factory_girl
        begin
          require "factory_girl"
        rescue LoadError
        end

        # try and require machinist, and bueprints while we're at it
        begin
          require "machinist"
          require "#{Rails.root}/blueprints"
          require "#{Rails.root}/features/blueprints"
          require "#{Rails.root}/spec/blueprints"
          require "#{Rails.root}/test/blueprints"
        rescue LoadError
        end
      end
    end
  end
end