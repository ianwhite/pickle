# use pluginized rpsec if it exists
rspec_base = File.expand_path(File.dirname(__FILE__) + '/../rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base) and !$LOAD_PATH.include?(rspec_base)

require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'rake/rdoctask'

plugin_name = 'pickle'

task :default => :spec

task :cruise do
  # run the garlic task, capture the output, if succesful make the docs and copy them to ardes
  begin
    sh "cp garlic_example.rb garlic.rb"
    sh "rake get_garlic"
    sh "rake garlic:clean"
    sh "rake garlic:all > garlic_report.txt"
    
    # send abridged rpeort
    report = File.read('garlic_report.txt').sub(/^.*?==========/m, '==========')
    report = "garlic report for #{plugin_name}\n#{`git log -n 1 --pretty=oneline --no-color`}\n" + report
    File.open('garlic_report.txt', 'w+') {|f| f << report }
    sh "scp -i ~/.ssh/ardes garlic_report.txt ardes@ardes.com:~/subdomains/plugins/httpdocs/doc/#{plugin_name}_garlic_report.txt"

    # build doc and send that
    cd "garlic/work/edge/vendor/plugins/#{plugin_name}" do
      sh "rake doc:all"
      sh "scp -i ~/.ssh/ardes -r doc ardes@ardes.com:~/subdomains/plugins/httpdocs/doc/#{plugin_name}"
    end
    
  ensure
    puts File.read('garlic_report.txt')
  end
end

desc "Run the specs for #{plugin_name}"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts  = ["--colour"]
end

namespace :spec do
  desc "Generate RCov report for #{plugin_name}"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_files  = FileList['spec/**/*_spec.rb']
    t.rcov        = true
    t.rcov_dir    = 'doc/coverage'
    t.rcov_opts   = ['--text-report', '--exclude', "spec/,rcov.rb,#{File.expand_path(File.join(File.dirname(__FILE__),'../../..'))}"] 
  end

  namespace :rcov do
    desc "Verify RCov threshold for #{plugin_name}"
    RCov::VerifyTask.new(:verify => "spec:rcov") do |t|
      t.threshold = 100.0
      t.index_html = File.join(File.dirname(__FILE__), 'doc/coverage/index.html')
    end
  end
  
  desc "Generate specdoc for #{plugin_name}"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_files  = FileList['spec/**/*_spec.rb']
    t.spec_opts   = ["--format", "specdoc:SPECDOC"]
   end

  namespace :doc do
    desc "Generate html specdoc for #{plugin_name}"
    Spec::Rake::SpecTask.new(:html => :rdoc) do |t|
      t.spec_files    = FileList['spec/**/*_spec.rb']
      t.spec_opts     = ["--format", "html:doc/rspec_report.html", "--diff"]
    end
  end
end

task :rdoc => :doc
task "SPECDOC" => "spec:doc"

desc "Generate rdoc for #{plugin_name}"
Rake::RDocTask.new(:doc) do |t|
  t.rdoc_dir = 'doc'
  t.main     = 'README'
  t.title    = "#{plugin_name}"
  t.template = ENV['RDOC_TEMPLATE']
  t.options  = ['--line-numbers', '--inline-source', '--all']
  t.rdoc_files.include('README.rdoc', 'SPECDOC', 'MIT-LICENSE', 'CHANGELOG')
  t.rdoc_files.include('lib/**/*.rb')
end

namespace :doc do 
  desc "Generate all documentation (rdoc, specdoc, specdoc html and rcov) for #{plugin_name}"
  task :all => ["spec:doc:html", "spec:doc", "spec:rcov", "doc"]
end

# load up garlic if it's here
if File.directory?(File.join(File.dirname(__FILE__), 'garlic'))
  require File.join(File.dirname(__FILE__), 'garlic/lib/garlic_tasks')
  require File.join(File.dirname(__FILE__), 'garlic')
end

desc "clone the garlic repo (for running ci tasks)"
task :get_garlic do
  sh "git clone git://github.com/ianwhite/garlic.git garlic"
end