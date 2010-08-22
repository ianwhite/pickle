require 'pickle/adapter_map'

module Pickle
  class Config
    attr_writer :adapters, :factories, :aliases, :labels, :mappings, :predicates
    
    def initialize(&block)
      configure(&block) if block_given?
    end
    
    def configure(&block)
      yield(self)
    end
    
    # hash of factory names => adapter instances
    #
    # defaults to all adapters available from adapter classes specifies by #adapters.
    # It's sublcass of Hash, so you can add your own adapters in an ad-hoc manner.
    #
    #   Config.new do |c|
    #     c.adapters = [:machinist]
    #     c.adapter_map['file'] = MyFileAdapter.new
    #   end
    #
    # @return Hash
    def adapter_map
      @adapter_map ||= AdapterMap.new(adapter_classes)
    end
    
    # adapters that pickle should use to create models
    #
    # set this to symbols found in pickle/adapters, or adapter classes
    #
    #   Config.new do |c|
    #     c.adapters = [:factory_girl, MyAdapter]
    #   end
    # 
    # @return Array of symbols or adapter classes
    def adapters
      @adapters ||= [:machinist, :factory_girl, :orm]
    end
    
    # returns adapter classes
    # @see #adapters
    # @return Array of adapter classes
    def adapter_classes
      adapters.map do |adapter| 
        if adapter.is_a?(Class)
          adapter
        else
          require "pickle/adapters/#{adapter}"
          "pickle/adapter/#{adapter}".classify.constantize
        end
      end
    end
    
    # list of predicate names that the pickle parser should be aware of
    #
    # By default pickle_steps.rb just matches predicates in double quotes, using #predicate_names
    # can make for more readable steps as it adds these to the <tt>pickle_predicate</tt> Regexp
    # without quotes.
    #
    #  config.predicates = ['absurdly large', 'empty']
    #
    # @return Array
    def predicates
      @predicates ||= []
    end
    
    # list of factory/model names that the pickle parser should be aware of
    #
    # By default pickle_steps.rb just matches factory names that are a single word (with underscores).
    # using #factory_names lets you add extra expressions (for example with spaces instead of underscores)
    #
    #  config.factories = ['admin user', 'site owner']
    #  # this will mean that #pickle_ref will match 'the admin user', and the resulting factory name
    #  # will be 'admin_user'
    # 
    # @see #alias
    # @return Array String
    def factories
      @factories ||= []
    end
        
    # alias a bunch of names to another name(s)
    #
    #  config.alias 'admin', 'admin user', :to => 'external_lib_admin_user' # where External::Lib::Admin::User is one of your models
    def alias(*args)
      options = args.extract_options!
      raise ArgumentError, "Usage: alias 'alias1' [, 'alias2', ...] :to => '<factory_name>'" unless args.any? && options[:to].is_a?(String)
      args.each {|aliaz| self.aliases[aliaz] = options[:to]}
    end
    
    def aliases
      @aliases ||= {}
    end
    
    class Mapping < Struct.new(:search, :replacement)
    end
    
    def mappings
      @mapping ||= []
    end
        
    # Usage: map 'me', 'myself', 'I', :to => 'user: "me"'
    def map(*args)
      options = args.extract_options!
      raise ArgumentError, "Usage: map 'search' [, 'search2', ...] :to => 'replace'" unless args.any? && options[:to].is_a?(String)
      args.each do |search|
        self.mappings << Mapping.new(search, options[:to])
      end
    end
  end
end
