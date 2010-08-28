require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

desc "Generate RCov report"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files  = FileList['spec/**/*_spec.rb']
  t.rcov        = true
  t.rcov_dir    = 'doc/coverage'
  t.rcov_opts   = ['--text-report', '--exclude', "gems/,features/,/Library,spec/,rcov.rb"] 
end