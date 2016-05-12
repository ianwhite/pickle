$:.push File.expand_path("../lib", __FILE__)
require "pickle/version"

Gem::Specification.new do |s|
  s.name = "pickle"
  s.version = Pickle::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.licenses = ["MIT"]
  s.authors = ["Ian White", "James Le Cuirot"]
  s.description = "Easy model creation and reference in your cucumber features"
  s.summary = "Easy model creation and reference in your cucumber features."
  s.email = ["ian.w.white@gmail.com", "chewi@aura-online.co.uk"]
  s.homepage = "https://github.com/ianwhite/pickle"

  s.rubyforge_project = "pickle"
  s.required_rubygems_version = ">= 1.3.6"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_dependency "cucumber" # , ">=0.8"
  s.add_dependency "rake"
   
  s.add_development_dependency "rack"
  s.add_development_dependency "bundler"
  s.add_development_dependency "git"
  s.add_development_dependency "yard"
  s.add_development_dependency "rspec-rails", "~>3.0"
  s.add_development_dependency "rails", "~>4.2.6"
  s.add_development_dependency "cucumber-rails"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "fabrication", '~> 2.0'
  s.add_development_dependency "machinist" # , "~>2.0"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "capybara"
  s.add_development_dependency "sqlite3"
end
