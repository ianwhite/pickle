require 'pickle'

# make cucumber world pickle aware
World(Pickle::Session)

# shortcuts to regexps for use in step definition regexps
class << self
  delegate :capture_model, :capture_fields, :capture_factory, :capture_plural_factory, :capture_predicate, :to => 'Pickle.parser'
end
