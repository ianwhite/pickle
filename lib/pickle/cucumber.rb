require 'pickle'

# make cucumber pickle aware
World(Pickle::Dsl)

# shortcuts to regexps for use in step definition regexps
class << self
  delegate :pickle_ref, :pickle_plural, :pickle_fields, :pickle_predicate, :pickle_value, :pickle_label, :to => 'Pickle.parser'
end
