require 'pickle'
require 'pickle/path'

# make world pickle/path aware
World do |world|
  class << world
    include Pickle::Path
  end
  world
end