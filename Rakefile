# use pluginized rpsec if it exists
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base) and !$LOAD_PATH.include?(rspec_base)

require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'hanna/rdoctask'
require 'rake/gempackagetask'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'pickle/version'

plugin_name = 'pickle'

task :default => [:spec]

plugins_base = File.expand_path(File.join(File.dirname(__FILE__), '..'))
cucumber_base = File.join(plugins_base, 'cucumber/lib')
if File.exists?(cucumber_base) && plugins_base =~ /\/vendor\/plugins$/ # if we're in rails app
  $:.unshift(cucumber_base)
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "--format progress -r features/step_definitions features"
  end
  
  namespace :features do
    Cucumber::Rake::Task.new(:full) do |t|
      t.cucumber_opts = '-r features/step_definitions features'
    end
  end
end

desc "Run the specs for #{plugin_name}"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts  = ["--colour"]
end

desc "Generate RCov report for #{plugin_name}"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files  = FileList['spec/**/*_spec.rb']
  t.rcov        = true
  t.rcov_dir    = 'doc/coverage'
  t.rcov_opts   = ['--text-report', '--exclude', "spec/,rcov.rb,#{File.expand_path(File.join(File.dirname(__FILE__),'../../..'))}"] 
end

namespace :rcov do
  desc "Verify RCov threshold for #{plugin_name}"
  RCov::VerifyTask.new(:verify => :rcov) do |t|
    t.threshold = 100.0
    t.index_html = File.join(File.dirname(__FILE__), 'doc/coverage/index.html')
  end
end

task :rdoc => :doc

desc "Generate rdoc for #{plugin_name}"
Rake::RDocTask.new(:doc) do |d|
  d.rdoc_dir = 'doc'
  d.main     = 'README.rdoc'
  d.title    = "#{plugin_name} API Docs (#{`git log HEAD -1 --pretty=format:"%H"`[0..6]})"
  d.rdoc_files.include('README.rdoc', 'History.txt', 'License.txt', 'Todo.txt').
    include('lib/**/*.rb')
end

namespace :doc do
  task :gh_pages => :doc do
    `git branch -m gh-pages orig-gh-pages`
    `mv doc doctmp`
    `git checkout -b gh-pages origin/gh-pages`
    if `cat doc/index.html | grep "<title>"` != `cat doctmp/index.html | grep "<title>"`
      `rm -rf doc`
      `mv doctmp doc`
      `git add doc`
      `git commit -m "Update API docs"`
      `git push`
      `git checkout master`
    end
    `git branch -D gh-pages`
    `git branch -m orig-gh-pages gh-pages`
  end
end

task :cruise do
  sh "garlic clean && garlic all"
  Rake::Task['doc:gh_pages'].invoke
  puts "The build is GOOD"
end

spec = Gem::Specification.new do |s|
  s.name          = plugin_name
  s.version       = Pickle::Version::String
  s.summary       = "Easy model creation and reference in your cucumber features"
  s.description   = "Easy model creation and reference in your cucumber features"
  s.author        = "Ian White"
  s.email         = "ian.w.white@gmail.com"
  s.homepage      = "http://github.com/ianwhite/pickle/tree"
  s.has_rdoc      = true
  s.rdoc_options << "--title" << "Pickle" << "--line-numbers"
  s.test_files    = FileList["spec/**/*_spec.rb"]
  s.files         = FileList["lib/**/*.rb", "rails_generators/**/*.rb", "License.txt", "README.textile", "Todo.txt", "History.txt"]
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

desc "Generate pickle.gemspec file"
task :build do
  File.open('pickle.gemspec', 'w') {|f| f.write spec.to_ruby }
end