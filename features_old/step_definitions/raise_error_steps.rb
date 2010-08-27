Then /^the following should raise Pickle::Session::ModelNotKnownError: "([^"]*)"$/ do |step|
  lambda { steps step }.should raise_error(Pickle::Session::ModelNotKnownError)
end