require 'active_support'
require 'pickle/config'

module Pickle
  module Version
    Major = 0
    Minor = 1
    Tiny  = 1
    
    String = [Major, Minor, Tiny].join('.')
  end
  
  def self.config
    yield(Config.default) if block_given?
    Config.default
  end
end