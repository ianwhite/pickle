# inject the pickle session into integration session
Pickle::Injector.inject Pickle::Session, :into => ActionController::Integration::Session

# make some Regexp shortcuts for use in steps
MatchModel  = Pickle::Parser::Match::Model
MatchFields = Pickle::Parser::Match::Fields

# start with some obvious steps
Given(/^(#{MatchModel}) exists$/) do |name|
  create_model(name)
end

Given(/^(#{MatchModel}) exists with (#{MatchFields})$/) do |name, fields|
  create_model(name, fields)
end

Then(/^(#{MatchModel}) should exist with (#{MatchFields})$/) do |name, fields|
  find_model(name, fields).should_not == nil
end

Then(/^(#{MatchModel}) should be (?:an? )?(\w+)$/) do |name, predicate|
  model(name).should send("be_#{predicate}")
end

Then(/^(#{MatchModel}) should not be (?:an? )?(\w+)$/) do |name, predicate|
  model(name).should_not send("be_#{predicate}")
end
