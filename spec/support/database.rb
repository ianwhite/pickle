case ENV['PICKLE_SPEC_DB']
  
when 'data_mapper'
  require 'dm-core'
when 'mongoid'
  require 'mongoid'
else
  require 'active_record'

end