# auto require for active record, datamapper and mongoid orms
require 'pickle/orm_adapters/active_record' if defined?(ActiveRecord::Base)
require 'pickle/orm_adapters/data_mapper'   if defined?(DataMapper::Resource)
require 'pickle/orm_adapters/mongoid'       if defined?(Mongoid::Document)