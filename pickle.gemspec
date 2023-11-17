$:.push File.expand_path("../lib", __FILE__)
require "pickle/version"

Gem::Specification.new do |s|
  s.name = "pickle"
  s.version = Pickle::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.licenses = ["MIT"]
  s.authors = ["Ian White", "James Le Cuirot", "Mathieu Jobin"]
  s.description = "Easy model creation and reference in your cucumber features"
  s.summary = "Easy model creation and reference in your cucumber features."
  s.email = ["ian.w.white@gmail.com", "chewi@aura-online.co.uk", "mathieu.jobin@gmail.com"]
  s.homepage = "https://github.com/ianwhite/pickle"

  s.rubyforge_project = "pickle"
  s.required_rubygems_version = ">= 2.7"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "cucumber", ">=3.0", "< 10.0"
  s.add_dependency "rake"

  s.add_development_dependency "rack"
  s.add_development_dependency "bundler"
  s.add_development_dependency "git"
  s.add_development_dependency "yard"
  s.add_development_dependency "rspec-rails", ">= 3.0"
  s.add_development_dependency "rspec-mocks", ">= 3.12.4"
  s.add_development_dependency "rails", ">= 6.0", "< 8.0"
  s.add_development_dependency "cucumber-rails"
  s.add_development_dependency "factory_bot"
  s.add_development_dependency "fabrication", '~> 2.0'
  s.add_development_dependency "machinist" # , "~>2.0"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "capybara"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "codecov"
end
