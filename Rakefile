# use pluginized rpsec if it exists
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base) and !$LOAD_PATH.include?(rspec_base)

require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'cucumber/rake/task'

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
  t.rcov_opts   = ['--text-report', '--exclude', "gems/,features/,/Library,spec/,rcov.rb,#{File.expand_path(File.join(File.dirname(__FILE__),'../../..'))}"] 
end

namespace :rcov do
  desc "Verify RCov threshold for #{PluginName}"
  RCov::VerifyTask.new(:verify => :rcov) do |t|
    t.threshold = 98.67
    t.index_html = File.join(File.dirname(__FILE__), 'doc/coverage/index.html')
  end
end

desc "Run features for #{PluginName} (progress)"
Cucumber::Rake::Task.new(:cucumber => [:cucumber_test_app]) do |t|
  t.cucumber_opts = ['--format', 'pretty', '--require', 'features']
end

desc "setup a rails app for running cucumber"
file "cucumber_test_app" do
  puts "** setting up cucumber test app ** (rails 2.3 only at present)"
  Rake::Task['cucumber:setup'].invoke
end

namespace :cucumber do
  task :setup do
    rm_rf "cucumber_test_app"
    sh "rails cucumber_test_app"
    cd "cucumber_test_app" do
      sh "script/generate rspec"
      sh "script/generate cucumber"
    end
    sh "ln -s #{File.expand_path('.')} cucumber_test_app/vendor/plugins/pickle"
  end
end

task :ci => ['rcov:verify', 'cucumber']

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

begin
  require 'yard'
  
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files   = ['lib/**/*.rb', 'generators/**/*.rb']
  end

rescue LoadError
  puts "YARD not available for doc tasks. Install it with: sudo gem install yard"
end