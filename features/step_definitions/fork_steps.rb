# typed: true
# example of making your own matcher with the pickle backend
When.new(/^#{capture_model} should be tine of #{capture_model}$/) do |tine, fork|
  expect(model(fork).tines).to include(model(tine))
end
