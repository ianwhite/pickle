require 'rubygems'
require 'rspec'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'pickle'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

require 'active_support'
