require 'ostruct'

module Pickle
  class << self
    def config(&block)
      @config ||= Config.new
    ensure
      @config.configure(&block) if block_given?
    end
    alias_method :configure, :config
  end
  
  class Config
    attr_writer :adapters, :factories, :mappings
    
    def initialize(&block)
      configure(&block) if block_given?
    end
    
    def configure(&block)
      yield(self)
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