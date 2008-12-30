module Pickle
  class Config
    attr_writer :adapters, :factories, :mappings
    
    # default configuration object
    def self.default
      @default ||= new
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

    def names
      factories.keys.sort
    end
    
    def mappings
      @mappings ||= []
    end
    
    def map(search, options)
      raise ArgumentError, "Usage: map 'search', :to => 'replace'" unless search.is_a?(String) && options[:to].is_a?(String)
      self.mappings << {:search => search, :replace => options[:to]}
    end
  end
end