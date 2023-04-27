source "https://rubygems.org"

git_source(:github){ |repo_name| "https://github.com/#{repo_name}.git" }

gemspec :path => "."

ruby ENV['RUBY_VERSION']
gem "rails", "~> #{ENV['RAILS_VERSION']}.0"
gem "cucumber", "~> #{ENV['CUKES_VERSION']}"
gem "cucumber-rails"
gem 'fabrication', github: 'mathieujobin/fabrication', ref: '923cf6fcefd0566b1d6be7bd2f685b89388f4800'
