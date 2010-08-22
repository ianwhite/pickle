require 'pickle'

# auto require for active record, datamapper and mongoid
require 'pickle/orm_adapters/active_record' if defined?(ActiveRecord::Base)
require 'pickle/orm_adapters/data_mapper'   if defined?(DataMapper::Resource)
require 'pickle/orm_adapters/mongoid'       if defined?(Mongoid::Document)

# make cucumber pickle aware
World(Pickle::Dsl)

# shortcuts to regexps for use in step definition regexps
class << self
  delegate :pickle_ref, :pickle_plural, :pickle_fields, :pickle_predicate, :to => 'Pickle.parser'
end
