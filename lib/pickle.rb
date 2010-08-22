require 'active_support'
require 'pickle/version'
require 'pickle/orm_adapter'
require 'pickle/adapter'
require 'pickle/default_config'
require 'pickle/parser/matchers'
require 'pickle/parser/canonical'
require 'pickle/parser'
require 'pickle/config'
require 'pickle/ref'
require 'pickle/jar'
require 'pickle/session/conversion'
require 'pickle/session/adapters'
require 'pickle/session/api'
require 'pickle/session'
require 'pickle/make_matcher'
require 'pickle/dsl'

# the pickle module acts as a 'mother', holding shared configuration for the duration of execution
#
# In cucumber, the Pickle::Session module is included into the world, which defaults to using
# the (global) Pickle.config
#
# TODO: show how to instantiate multiple pickle mothers
module Pickle
  extend self
  
  def config
    @config ||= Pickle::Config.new
  end
  
  def configure(&block)
    config.configure(&block)
  end
  
  def parser
    @parser ||= Pickle::Parser.new.tap {|p| p.config = config}
  end
end