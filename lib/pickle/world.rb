require 'pickle'

# auto require for active record, datamapper, mongoid and sequel
require 'pickle/adapters/active_record' if defined?(ActiveRecord::Base)
require 'pickle/adapters/data_mapper'   if defined?(DataMapper::Resource)
require 'pickle/adapters/mongoid'       if defined?(Mongoid::Document)
require 'pickle/adapters/sequel'        if defined?(Sequel::Model)

# make cucumber world pickle aware
World(Pickle::Session)

# shortcuts to regexps for use in step definition regexps
class << self
  delegate :capture_model, :capture_fields, :capture_factory, :capture_plural_factory, :capture_predicate, :capture_value, :to => 'Pickle.parser'
end
