# typed: false
# example of making your own matcher with the pickle backend
Then(/^#{capture_model} should be tine of #{capture_model}$/) do |tine, fork|
  expect(model(fork).tines).to include(model(tine))
end
