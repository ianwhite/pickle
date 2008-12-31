# example of making your own matcher with the pickle backend
Then(/^#{CaptureModel} should belong to #{CaptureModel}$/) do |tine, fork|
  model(fork).tines.should include(model(tine))
end