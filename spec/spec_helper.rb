require 'rubygems'
require 'spec'
require 'active_support'
require 'active_record'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'pickle'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}