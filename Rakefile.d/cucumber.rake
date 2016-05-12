require 'cucumber/rake/task'

desc "Run features"
Cucumber::Rake::Task.new(:cucumber => [:cucumber_test_app]) do |t|
  t.cucumber_opts = ['--format', 'pretty', '--require', 'features']
end

desc "setup a rails app for running cucumber"
file "cucumber_test_app" do
  puts "** setting up cucumber test app **"
  Rake::Task['cucumber:setup'].invoke
end

namespace :cucumber do
  task :setup do
    Bundler.with_clean_env do
      gemfile = "cucumber_test_app/Gemfile"
      rm_rf "cucumber_test_app"
      sh "bundle exec rails new cucumber_test_app --skip-javascript --skip-sprockets"
      sh "echo 'gem \"cucumber-rails\", :require => false' >> #{gemfile}"
      sh "echo 'gem \"rspec-rails\", \"~>3.0\"' >> #{gemfile}"
      sh "echo 'gem \"capybara\"' >> #{gemfile}"
      sh "echo 'gem \"pickle\", path: \"#{__dir__}/..\"' >> #{gemfile}"
      sh "bundle install --gemfile=#{gemfile}"
    end
  end
end
