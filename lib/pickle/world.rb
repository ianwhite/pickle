require 'pickle'

# make cucumber world pickle aware
World do |world|
  class << world
    include Pickle::Session
  end
  world
end

# shortcuts to regexps for use in step definition regexps
class << self
  delegate :capture_model, :capture_fields, :capture_factory, :capture_plural_factory, :capture_predicate, :to => 'Pickle.parser'
end
