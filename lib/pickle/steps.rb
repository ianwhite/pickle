# inject the pickle session into integration session
Pickle::Injector.inject Pickle::Session, :into => ActionController::Integration::Session

# make some Regexp shortcuts for use in steps
def match_model
  Pickle::Parser.match_model
end

def match_fields
  Pickle::Parser::MatchFields
end

# start with some obvious steps
Given(/^(#{match_model}) exists$/) do |name|
  create_model(name)
end

Given(/^(#{match_model}) exists with (#{match_fields})$/) do |name, fields|
  create_model(name, fields)
end

Then(/^(#{match_model}) should exist with (#{match_fields})$/) do |name, fields|
  find_model(name, fields).should_not == nil
end

Then(/^(#{match_model}) should be (?:an? )?(\w+)$/) do |name, predicate|
  model(name).should send("be_#{predicate}")
end

Then(/^(#{match_model}) should not be (?:an? )?(\w+)$/) do |name, predicate|
  model(name).should_not send("be_#{predicate}")
end
