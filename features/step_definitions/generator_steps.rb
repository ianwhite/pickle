# typed: false
Before('@gen') do
  `mv #{Rails.root}/features/ #{Rails.root}/features.orig/ > /dev/null 2>&1`
end

After('@gen') do
  `rm -rf #{Rails.root}/features`
  `mv #{Rails.root}/features.orig/ #{Rails.root}/features/ > /dev/null 2>&1`
end

Given(/^cucumber has been freshly generated$/) do
  Bundler.with_clean_env do
    `cd #{Rails.root}; rails g cucumber:install -f --capybara`
  end
end

Given(/^pickle path email has been freshly generated$/) do
  Bundler.with_clean_env do
    `cd #{Rails.root}; rails g pickle paths email -f`
  end
end

Given(/^env\.rb already requires (.+)$/) do |file|
  File.open("#{Rails.root}/features/support/env.rb", "a") do |env|
    env << "require '#{file}'\n"
  end
end

When(/^I run "(.*)"$/) do |command|
  Bundler.with_clean_env do
    @output = `cd #{Rails.root}; #{command}`
  end
end

Then(/^I should see "(.*)"$/) do |text|
  expect(@output).to include(text)
end

Then(/^the file (.+?) should exist$/) do |file|
  expect(File.exist?("#{Rails.root}/#{file}")).to eq(true)
end

Then(/^the file (.+?) should match \/(.*?)\/$/) do |file, regexp|
  expect(File.read("#{Rails.root}/#{file}")).to match(/#{regexp}/m)
end

Then(/^the file (.+?) should not match \/(.*?)\/$/) do |file, regexp|
  expect(File.read("#{Rails.root}/#{file}")).not_to match(/#{regexp}/m)
end

Then /^the file ([^ ]+) should be identical to the local (.+)$/ do |generated_file, source_file|
  expect(File.read("#{Rails.root}/#{generated_file}")).to eq(File.read("#{File.dirname(__FILE__)}/../#{source_file}"))
end
