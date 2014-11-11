Then /^the following should raise an? ([\w:]+):$/ do |error, step|
  lambda { steps step }.should raise_error(error.constantize)
end

Then /^the following should raise an? ([\w:]+) with "([^"]*)":$/ do |error, message, step|
  lambda { steps step }.should raise_error(error.constantize, message)
end