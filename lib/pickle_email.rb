require 'pickle/email'
require 'pickle/email/parser'

# add email parser expressions
Pickle::Parser.send :include, Pickle::Email::Parser

if defined? ActionController::Integration::Session
  ActionController::Integration::Session.send :include, Pickle::Email
end

class << self
  delegate :capture_email, :to => 'Pickle.parser'
end