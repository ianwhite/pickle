source "http://rubygems.org"

gem "yard"
gem "rake"
gem "cucumber", "~>0.8.5"
gem "rspec", "~>1.3.0"

group :test do
  if ENV['PICKLE_RAILS3']
    gem "rails", "~>3.0.0"
    gem "mongoid", "~>2.0.0.beta.17"
    gem "rack", "~>1.2.1"
  else
    gem "rails", "~>2.3.9"
    gem "mongoid", "~>1.9.2"
    gem "rack", "~>1.1.0"
  end

  gem "rspec-rails", "~>1.3.2"
  gem "aruba"
  gem "cucumber-rails", "~>0.3.2"
  gem "factory_girl"
  gem "machinist"
  gem "jeweler"
  gem "rcov"
  gem "database_cleaner"
  gem "capybara"
  gem "webrat"
  gem "sqlite3-ruby"
  gem "ruby-debug"
  gem "datamapper"
  gem "dm-sqlite-adapter"
  gem 'machinist_mongo'
end