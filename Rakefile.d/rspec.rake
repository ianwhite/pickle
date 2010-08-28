require 'spec/rake/spectask'

desc "Run the specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts  = ["--colour"]
end

pickle_orm_adapters = [:data_mapper, :active_record, :mongoid]

namespace :spec do
  pickle_orm_adapters.each do |orm|
    desc "Run the #{orm} specs"
    task orm do
      sh "export PICKLE_SPEC_DB=#{orm} && spec spec/pickle/orm_adapters/#{orm}_spec.rb"
    end
  end
  
  task :all do
    Rake::Task['spec'].invoke
    pickle_orm_adapters.each do |orm|
      Rake::Task["spec:#{orm}"].invoke
    end
  end
end