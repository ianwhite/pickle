# typed: false
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then(/^(.+?) should match route \/(.+?)$/) do |page, route|
  regexp = route.gsub(/:(\w*?)id/,'\d+')
  expect(path_to(page)).to match(/#{regexp}/)
end

When(/^I go to (.+)$/) do |page|
  visit path_to(page)
end

Then(/^I should be at (.+)$/) do |page|
  expect(current_url).to match(/#{path_to(page)}/)
end
