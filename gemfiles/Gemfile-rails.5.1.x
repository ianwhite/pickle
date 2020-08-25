source "http://rubygems.org"

# Bundler 1.x default to insecure http:// for github: shortcut
git_source(:github){ |repo_name| "https://github.com/#{repo_name}.git" }

gemspec :path => ".."

gem "rails", "~> 5.1.0"
gem "cucumber", "~> 3.2"
gem 'fabrication', github: 'mathieujobin/fabrication', ref: '923cf6fcefd0566b1d6be7bd2f685b89388f4800'
