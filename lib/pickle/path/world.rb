require 'pickle'
require 'pickle/path'

# make world pickle/path aware
World do |world|
  world.extend Pickle::Path
  world
end