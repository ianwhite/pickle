require 'pickle/find_path_for'

if defined? ActionController::Integration::Session
  ActionController::Integration::Session.send :include, Pickle::FindPathFor
end