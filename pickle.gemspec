$:.push File.expand_path("../lib", __FILE__)
require "pickle/version"

Gem::Specification.new do |s|
  s.name = "pickle"
  s.version = Pickle::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.authors = ["Ian White"]
  s.description = "Easy model creation and reference in your cucumber features"
  s.summary = "Easy model creation and reference in your cucumber features."
  s.email = "ian.w.white@gmail.com"
  s.homepage = "http://github.com/ianwhite/pickle"

  s.rubyforge_project = "orm_adapter"
  s.required_rubygems_version = ">= 1.3.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_dependency "cucumber", ">=0.8"
  s.add_dependency "rake", "=0.8.7'
   
  s.add_development_dependency "rack", "~>1.2.1"
  s.add_development_dependency "bundler"
  s.add_development_dependency "git"
  s.add_development_dependency "yard"
  s.add_development_dependency "rspec-rails", "~>2.5.0"
  s.add_development_dependency "rails", "~>3.0.5"
  s.add_development_dependency "cucumber-rails", ">=0.3.2"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "machinist"
  s.add_development_dependency "rcov"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "capybara"
  s.add_development_dependency "sqlite3-ruby"
end