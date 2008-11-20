garlic do
  repo 'rails', :url => 'git://github.com/rails/rails'
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'
  repo 'factory_girl', :url => 'git://github.com/thoughtbot/factory_girl'
  repo 'cucumber', :url => 'git://github.com/aslakhellesoy/cucumber.git'
  repo 'pickle', :path => '.'

  target '2.1-stable', :branch => 'origin/2-1-stable'
  target '2.2-stable', :branch => 'origin/2-2-stable'
  
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
