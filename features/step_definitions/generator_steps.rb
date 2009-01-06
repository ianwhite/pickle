Given(/^cucumber has not been generated$/) do
  `rm -rf #{Rails.root}/features`
end

Given(/^cucumber has been generated$/) do
  Given "cucumber has not been generated"
  `cd #{Rails.root}; script/generate cucumber -f`
end

Given /^env\.rb already requires pickle$/ do
  File.open("#{Rails.root}/features/support/env.rb", "a") do |env|
    env << "require 'pickle'\n"
  end
end

When(/^I run "(.*)"$/) do |command|
  @output = `cd #{Rails.root}; #{command}`
end

Then(/^I should see "(.*)"$/) do |text|
  @output.should include(text)
end

Then(/^the file (.+?) should exist$/) do |file|
  File.exist?("#{Rails.root}/#{file}").should == true
end

Then(/^the file (.+?) should contain "(.*?)"$/) do |file, text|
  File.read("#{Rails.root}/#{file}").should include(text)
end

Then(/^the file (.+?) should not contain "(.*?)"$/) do |file, text|
  File.read("#{Rails.root}/#{file}").should_not include(text)
end


