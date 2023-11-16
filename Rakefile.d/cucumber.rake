require 'cucumber/rake/task'

desc "Run features"
Cucumber::Rake::Task.new(:cucumber => [:cucumber_test_app]) do |t|
  t.cucumber_opts = %w[--format pretty --require features -t] + ["'not @wip'"]
end

desc "setup a rails app for running cucumber"
file "cucumber_test_app" do
  puts "** setting up cucumber test app **"
  Rake::Task['cucumber:setup'].invoke
end

namespace :cucumber do
  task :setup do
    current_gemfile = ENV['BUNDLE_GEMFILE']
    cukes_version = Gem.loaded_specs['cucumber'].version
    sqlite_version = Gem.loaded_specs['sqlite3'].version
    puts "Versions: Cucumber #{cukes_version}, SQLite #{sqlite_version}."
    Bundler.with_clean_env do
      gemfile = "cucumber_test_app/Gemfile"
      rm_rf "cucumber_test_app"
      sh "BUNDLE_GEMFILE=#{current_gemfile} bundle exec rails new cucumber_test_app --skip-spring --skip-javascript --skip-sprockets --skip-bootsnap"
      sh "echo 'gem \"cucumber\", \"~> #{cukes_version}\", :require => false' >> #{gemfile}"
      sh "sed -i'' -e 's/gem .sqlite3./gem \"sqlite3\", \"~> #{sqlite_version}\"/' #{gemfile}"
      sh "cat #{gemfile} | grep sqli"
      sh "echo 'gem \"cucumber-rails\", :require => false' >> #{gemfile}"
      sh "echo 'gem \"rspec-rails\", \"~>3.0\"' >> #{gemfile}"
      sh "echo 'gem \"pickle\", path: \"#{__dir__}/..\"' >> #{gemfile}"
      sh "bundle install --gemfile=#{gemfile}"
      sh "(cd cucumber_test_app ; bundle exec rake db:migrate)"
    end
  end
end
