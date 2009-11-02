# Pickle
require 'pickle/world'
require 'pickle/path/world'
require 'pickle/email/world'

Pickle.configure do |c|
  c.map 'I', :to => 'user: "me"'
  c.map 'killah fork', :to => 'fancy fork: "of cornwood"'
end
