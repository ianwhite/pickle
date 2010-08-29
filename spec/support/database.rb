case ENV['PICKLE_ORM']
when 'data_mapper'
  require 'dm-core'
when 'mongoid'
  require 'mongoid'
else
  require 'active_record'
end