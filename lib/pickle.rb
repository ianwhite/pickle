require 'active_support'
require 'pickle/adapter'
require 'pickle/config'
require 'pickle/parser'
require 'pickle/session'
require 'pickle/injector'

module Pickle
  module Version
    Major = 0
    Minor = 1
    Tiny  = 1
    
    String = [Major, Minor, Tiny].join('.')
  end
  
  class << self
    def match_model
      
    end
  end
end

# inject the pickle session into integration session if we have one
if defined?(ActionController::Integration::Session)
  Pickle::Injector.inject Pickle::Session, :into => ActionController::Integration::Session
end
# TODO - inject into other contexts here? 