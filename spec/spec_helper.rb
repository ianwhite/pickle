require 'rubygems'
require 'rspec'
require 'active_support'
require 'active_record'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'pickle'
require 'pickle/adapters/active_record'
