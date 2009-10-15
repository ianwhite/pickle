# use pluginized rpsec if it exists
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base) and !$LOAD_PATH.include?(rspec_base)

require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require 'pickle/version'

PluginName = 'pickle'

task :default => [:spec]

desc "Run the specs for #{PluginName}"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts  = ["--colour"]
end

desc "Generate RCov report for #{PluginName}"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files  = FileList['spec/**/*_spec.rb']
  t.rcov        = true
  t.rcov_dir    = 'doc/coverage'
  t.rcov_opts   = ['--text-report', '--exclude', "spec/,rcov.rb,#{File.expand_path(File.join(File.dirname(__FILE__),'../../..'))}"] 
end

namespace :rcov do
  desc "Verify RCov threshold for #{PluginName}"
  RCov::VerifyTask.new(:verify => :rcov) do |t|
    t.threshold = 100.0
    t.index_html = File.join(File.dirname(__FILE__), 'doc/coverage/index.html')
  end
end

# cucumber features require an enclosing rails app
plugins_base = File.expand_path(File.join(File.dirname(__FILE__), '..'))
cucumber_base = File.join(plugins_base, 'cucumber/lib')
if File.exists?(cucumber_base) && plugins_base =~ /\/vendor\/plugins$/ # if we're in rails app
  $:.unshift(cucumber_base)
  require 'cucumber/rake/task'

  desc "Run features for #{PluginName} (progress)"
  Cucumber::Rake::Task.new(:features) do |t|
    t.fork = true
    t.cucumber_opts = ['--format', 'progress', '--require', 'features']
  end
  
  desc "Run features for #{PluginName} (full output)"
  namespace :features do
    Cucumber::Rake::Task.new(:full) do |t|
      t.cucumber_opts = ['--format', 'pretty', '--require', 'features']
    end
  end
end

# the following optional tasks are for CI, gems and doc building
begin
  require 'hanna/rdoctask'
  require 'garlic/tasks'
  require 'grancher/task'
  
  task :cruise => ['garlic:all', 'doc:publish']
  
  Rake::RDocTask.new(:doc) do |d|
    d.options << '--all'
    d.rdoc_dir = 'doc'
    d.main     = 'README.rdoc'
    d.title    = "#{PluginName} API docs"
    d.rdoc_files.include('README.rdoc', 'History.txt', 'License.txt', 'Todo.txt', 'lib/**/*.rb')
  end

  namespace :doc do
    task :publish => :doc do
      Rake::Task['doc:push'].invoke unless uptodate?('.git/refs/heads/gh-pages', 'doc')
    end
    
    Grancher::Task.new(:push) do |g|
      g.keep_all
      g.directory 'doc', 'doc'
      g.branch = 'gh-pages'
      g.push_to = 'origin'
    end
  end
rescue LoadError
end

begin
  require 'jeweler'
  
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
    task :all => ['release', 'gemcutter:release']
  end
  
rescue LoadError
  puts "Jeweler not available for gem tasks. Install it with: sudo gem install jeweler"
end