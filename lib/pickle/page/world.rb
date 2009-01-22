require 'pickle'
require 'pickle/page'

# make world pickle/page aware
World do |world|
  class << world
    include Pickle::Page
  end
  world
end