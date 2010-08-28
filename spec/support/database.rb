if ENV['PICKLE_SPEC_DB'] == 'data_mapper'
  require 'dm-core'
elsif ENV['PICKLE_SPEC_DB'] == 'mongoid'
  require 'mongoid'
else
  require 'active_record'
end