require 'pickle'
require 'pickle/email'
require 'pickle/email/parser'

# add email parser expressions
Pickle::Parser.send :include, Pickle::Email::Parser

World(Pickle::Email)

# shortcuts for use in step regexps
class << self
  delegate :capture_email, :to => 'Pickle.parser'
end