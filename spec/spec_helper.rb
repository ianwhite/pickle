require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'active_support'
require 'active_record'
require 'factory_girl'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'pickle'
require 'pickle/adapters/active_record'
