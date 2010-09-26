require 'pickle'
require 'pickle/orm_adapters/autoload'

# make cucumber pickle aware
World(Pickle::Dsl)

# shortcuts to regexps for use in step definition regexps
class << self
  delegate :pickle_ref, :pickle_plural, :pickle_fields, :pickle_predicate, :pickle_value, :to => 'Pickle.parser'
end
