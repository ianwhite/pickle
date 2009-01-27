Then(/^(.+?) should match route \/(.+?)$/) do |page, route|
  regexp = route.gsub(/:(\w*?)id/,'\d+')
  path_to(page).should =~ /#{regexp}/
end

When(/^I go to (.+)$/) do |page|
  visit path_to(page)
end

Then(/^I should be at (.+)$/) do |page|
  request.path.should =~ /#{path_to(page)}/
end