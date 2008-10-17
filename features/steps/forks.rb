# example of making your own matcher with the pickle backend
Then(/^(#{MatchModel}) should belong to (#{MatchModel})$/) do |tine, fork|
  model(fork).tines.should include(model(tine))
end