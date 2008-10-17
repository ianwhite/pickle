# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.join(File.dirname(__FILE__), "../../../../config/environment"))
require 'spec/rails'

Pickle::Parser.factory_names = ['user', 'super_admin', 'fast_car']
Pickle::Parser.active_record_names = ['event/create', 'event/update', 'user']
