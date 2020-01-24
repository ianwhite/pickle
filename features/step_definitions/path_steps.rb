# typed: true
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

When.new(/^(.+?) should match route \/(.+?)$/) do |page, route|
  regexp = route.gsub(/:(\w*?)id/,'\d+')
  expect(path_to(page)).to match(/#{regexp}/)
end

When.new(/^I go to (.+)$/) do |page|
  visit path_to(page)
end

When.new(/^I should be at (.+)$/) do |page|
  expect(current_url).to match(/#{path_to(page)}/)
end
