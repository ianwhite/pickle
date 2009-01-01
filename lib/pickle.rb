require 'active_support'
require 'pickle/adapter'
require 'pickle/config'
require 'pickle/parser'
require 'pickle/parser/with_session'
require 'pickle/session'
require 'pickle/injector'

# make the parser aware of models in the session (for fields refering to models)
Pickle::Parser.send :include, Pickle::Parser::WithSession

# inject the pickle session into integration session if we have one (TODO: inject into merb etc?)
if defined?(ActionController::Integration::Session)
  Pickle::Injector.inject Pickle::Session, :into => ActionController::Integration::Session
end

# shortcuts for useful regexps when defining pickle steps
CaptureModel      = Pickle.parser.capture_model
CaptureFactories  = Pickle.parser.capture_factories
CaptureFields     = Pickle.parser.capture_fields