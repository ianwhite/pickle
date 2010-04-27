require 'cucumber/rake/task'

desc "Run features"
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