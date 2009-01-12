Then(/^(.+?) page should match route \/(.+?)$/) do |page, route|
  regexp = route.gsub(/:(\w*?)id/,'\d+')
  page_to_path(page).should =~ /#{regexp}/
end