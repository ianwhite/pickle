require 'ostruct'

module Pickle
  class Config
    attr_writer :adapters, :factories, :mappings
    
    # default configuration object
    def self.default
      returning(@default ||= new) do |config|
        yield(config) if block_given?
      end
    end
    
    def adapters
      @adapters ||= [:machinist, :factory_girl, :active_record]
    end
    
    def adapter_classes
      adapters.map {|a| a.is_a?(Class) ? a : "pickle/adapter/#{a}".classify.constantize}
    end
    
    def factories
      @factories ||= adapter_classes.reverse.inject({}) do |factories, adapter|
        factories.merge(adapter.factories.inject({}){|h, f| h.merge(f.name => f)})
      end
    end

    def factory_names
      factories.keys
    end
    
    def mappings
      @mappings ||= []
    end
    
    # Usage: map 'me', 'myself', 'I', :to => 'user: "me"'
    def map(*args)
      options = args.extract_options!
      raise ArgumentError, "Usage: map 'search' [, 'search2', ...] :to => 'replace'" unless args.any? && options[:to].is_a?(String)
      search = args.size == 1 ? args.first.to_s : "(?:#{args.join('|')})"
      self.mappings << OpenStruct.new(:search => search, :replace => options[:to])
    end
  end
end