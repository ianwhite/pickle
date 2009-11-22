# test app setup
__APP__ = File.expand_path(File.join(File.dirname(__FILE__), '../app'))
require "#{__APP__}/app"
require "#{__APP__}/factories"
require "#{__APP__}/blueprints"

Pickle.configure do |c|
  c.map 'I', :to => 'user: "me"'
  c.map 'killah fork', :to => 'fancy fork: "of cornwood"'
end