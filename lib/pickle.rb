require 'active_support'
require 'pickle/version'
require 'pickle/adapter'
require 'pickle/config'
require 'pickle/parser'
require 'pickle/parser/with_session'
require 'pickle/session'

# make the parser aware of models in the session (for fields refering to models)
Pickle::Parser.send :include, Pickle::Parser::WithSession

module Pickle
  class << self
    def config
      @config ||= Config.new
    end
    
    def configure(&block)
      config.configure(&block)
    end
  
    def parser(options = {})
      @parser ||= Parser.new({:config => config}.merge(options))
    end
  end
end

if defined? ActionController::Integration::Session
  class ActionController::Integration::Session
    include Pickle::Session
    include Pickle::FindPathFor
  end
end

# shortcuts to regexps for use in step definition regexps
class << self
  delegate :capture_model, :capture_fields, :capture_factory, :capture_plural_factory, :capture_predicate, :to => 'Pickle.parser'
end
