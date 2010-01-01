Before('@gen') do
  `mv #{Rails.root}/features/ #{Rails.root}/features.orig/ > /dev/null 2>&1`
end

After('@gen') do
  `rm -rf #{Rails.root}/features`
  `mv #{Rails.root}/features.orig/ #{Rails.root}/features/ > /dev/null 2>&1`
end

Given(/^cucumber has been freshly generated$/) do
  `cd #{Rails.root}; script/generate cucumber -f --webrat`
end

Given(/^pickle path email has been freshly generated$/) do
  `cd #{Rails.root}; script/generate pickle path email`
end

Given(/^env\.rb already requires (.+)$/) do |file|
  File.open("#{Rails.root}/features/support/env.rb", "a") do |env|
    env << "require '#{file}'\n"
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

Then(/^the file (.+?) should match \/(.*?)\/$/) do |file, regexp|
  File.read("#{Rails.root}/#{file}").should match(/#{regexp}/m)
end

Then(/^the file (.+?) should not match \/(.*?)\/$/) do |file, regexp|
  File.read("#{Rails.root}/#{file}").should_not match(/#{regexp}/m)
end

Then /^the file ([^ ]+) should be identical to the local (.+)$/ do |generated_file, source_file|
  File.read("#{Rails.root}/#{generated_file}").should == File.read("#{File.dirname(__FILE__)}/../#{source_file}")
end