When /^I store "([^"]*)"$/ do |string|
  pickle.store string
end

Then /^there should be (\d+) strings$/ do |count|
  count.to_i.times do |i|
    pickle.retrieve :factory => 'string', :index => i
  end
end

Then /^#{pickle_ref} should be "([^"]*)"$/ do |ref, string|
  pickle.retrieve(ref).should == string
end
