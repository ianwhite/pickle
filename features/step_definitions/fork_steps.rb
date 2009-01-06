# example of making your own matcher with the pickle backend
Then(/^#{capture_model} should be tine of #{capture_model}$/) do |tine, fork|
  model(fork).tines.should include(model(tine))
end