# typed: false
Then /^the following should raise an? ([\w:]+):$/ do |error, step|
  expect { steps step }.to raise_error(error.constantize)
end

Then /^the following should raise an? ([\w:]+) with "([^"]*)":$/ do |error, message, step|
  expect { steps step }.to raise_error(error.constantize, message)
end
