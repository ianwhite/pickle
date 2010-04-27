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
end

Jeweler::GemcutterTasks.new

namespace :release do
  desc "release to github and gemcutter"
  task :all => ['release', 'gemcutter:release']
end