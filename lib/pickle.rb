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
  module Config
    class << self
      attr_accessor_with_default :active_record_names do
        Dir["#{RAILS_ROOT}/app/models/**/**"].reject{|f| f =~ /observer.rb$/}.map{|f| f.sub("#{RAILS_ROOT}/app/models/",'').sub(".rb",'')}
      end

      attr_accessor_with_default :factory_names do
        require 'factory_girl'
        Factory.factories.keys.map(&:to_s)
      end

      attr_accessor_with_default :model_names do
        (active_record_names | factory_names)
      end
      
      attr_accessor_with_default :model_mappings, []
      
      def map(search, options)
        raise ArgumentError, "Usage: map 'search', :to => 'replace'" unless search.is_a?(String) && options[:to].is_a?(String)
        Pickle::Config.model_mappings << [search, options[:to]]
      end
    end
  end
end