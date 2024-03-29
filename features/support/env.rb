# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_ROOT"] ||= File.expand_path(File.dirname(__FILE__) + '/../../cucumber_test_app')

Bundler.setup

require 'simplecov'
require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require 'capybara'
require 'cucumber/rails'
Capybara.default_selector = :css
ActionController::Base.allow_rescue = false

require 'database_cleaner/active_record'
DatabaseCleaner.strategy = :truncation

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end

# 'Fixnum' and 'Bignum' are deprecated since ruby-3.2 (both replaced by 'Integer')
# But 'machinist' still uses 'Fixnum', so we have to use workaround:
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.2')
  class Fixnum < Integer; end
end
