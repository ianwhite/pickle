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
    
  end
  
  module Config
    class << self
      attr_writer :model_names, :factory_names, :names, :mappings
      
      def model_names
        @model_names ||= Dir["#{RAILS_ROOT}/app/models/**/*.rb"].reject{|f| f =~ /observer.rb$/}.map{|f| f.sub("#{RAILS_ROOT}/app/models/",'').sub(".rb",'')}
      end

      def factory_names
        require 'factory_girl'
        @factory_names ||= Factory.factories.keys.map(&:to_s)
      end

      def names
        @names ||= (model_names | factory_names)
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