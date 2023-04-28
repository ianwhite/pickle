source "https://rubygems.org"

git_source(:github){ |repo_name| "https://github.com/#{repo_name}.git" }

gemspec :path => "."

# use ENV vars, with default value as fallback for local setup
ruby (ENV['RUBY_VERSION'] || '3.2.2')
gem "rails", "~> #{ENV['RAILS_VERSION'] || '7.0'}.0"
gem "cucumber", "~> #{ENV['CUKES_VERSION'] || '7.0'}"
gem "cucumber-rails"
gem 'fabrication', github: 'mathieujobin/fabrication', ref: '923cf6fcefd0566b1d6be7bd2f685b89388f4800'
