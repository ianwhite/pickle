require 'jeweler'
require 'pickle/version'

Jeweler::Tasks.new do |s|
  s.name = "pickle"
  s.version = Pickle::Version::String
  s.summary = "Easy model creation and reference in your cucumber features"
  s.description = "Easy model creation and reference in your cucumber features"
  s.email = "ian.w.white@gmail.com"
  s.homepage = "http://github.com/ianwhite/pickle/tree"
  s.authors = ["Ian White"]
  s.add_dependency('rspec', ">=1.3")
  s.add_dependency('cucumber', ">=0.8")
  s.add_dependency('yard')
  s.add_dependency('rake')
end

Jeweler::GemcutterTasks.new

namespace :release do
  desc "release to github and gemcutter"
  task :all => ['release', 'gemcutter:release']
end