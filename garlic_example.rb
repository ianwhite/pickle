# This is for running specs against target versions of rails
#
# To use do
#   - cp garlic_example.rb garlic.rb
#   - rake get_garlic
#   - [optional] edit this file to point the repos at your local clones of
#     rails, rspec, and rspec-rails
#   - rake garlic:all
#
# All of the work and dependencies will be created in the galric dir, and the
# garlic dir can safely be deleted at any point

garlic do
  repo 'rails', :url => 'git://github.com/rails/rails'#, :local => "~/dev/vendor/rails"
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'#, :local => "~/dev/vendor/rspec"
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'#, :local => "~/dev/vendor/rspec-rails"
  repo 'factory_girl', :url => 'git://github.com/thoughtbot/factory_girl'#, :local => "~/dev/vendor/factory_girl"
  repo 'cucumber', :url => 'git://github.com/aslakhellesoy/cucumber.git'#, :local => "~/dev/vendor/cucumber"
  repo 'pickle', :path => '.'

  target 'edge'
  target '2.1-stable', :branch => 'origin/2-1-stable'
  
  all_targets do
    prepare do
      plugin 'pickle', :clone => true
      plugin 'rspec'
      plugin 'rspec-rails' do
        sh "script/generate rspec -f"
      end
      plugin 'factory_girl'
      plugin 'cucumber' do
        sh "script/generate cucumber -f"
      end
    end
  
    run do
      cd "vendor/plugins/pickle" do
        sh "rake spec:rcov:verify && rake features"
      end
    end
  end
end
