require 'active_support'
require 'pickle/version'
require 'pickle/adapter'
require 'pickle/config'
require 'pickle/parser'
require 'pickle/session'
require 'pickle/session/parser'

# make the parser aware of models in the session (for fields refering to models)
Pickle::Parser.send :include, Pickle::Session::Parser

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