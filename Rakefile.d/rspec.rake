require 'spec/rake/spectask'

desc "Run the specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts  = ["--colour"]
end

namespace :spec do
  [:data_mapper, :active_record, :mongoid].each do |orm|
    desc "Run the #{orm} specs"
    task orm do
      sh "export PICKLE_SPEC_DB=#{orm} && spec spec/pickle/orm_adapters/#{orm}_spec.rb"
    end
  end
  
  task :all do
    Rake::Task['spec'].invoke
    Rake::Task['spec:active_record'].invoke
    Rake::Task['spec:data_mapper'].invoke
    Rake::Task['spec:mongoid'].invoke
  end
end