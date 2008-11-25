garlic do
  repo 'rails', :url => 'git://github.com/rails/rails'
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'
  repo 'factory_girl', :url => 'git://github.com/thoughtbot/factory_girl'
  repo 'cucumber', :url => 'git://github.com/aslakhellesoy/cucumber.git'
  repo 'pickle', :path => '.'

  ['origin/2-1-stable', 'origin/2-2-stable'].each do |rails|
  
    target "Rails: #{rails}", :tree_ish => rails do
      prepare do
        plugin 'pickle', :clone => true
        plugin 'rspec'
        plugin 'rspec-rails' do
          `script/generate rspec -f`
        end
        plugin 'factory_girl'
        plugin 'cucumber' do
          `script/generate cucumber -f`
        end
      end
  
      run do
        cd "vendor/plugins/pickle" do
          sh "rake spec:rcov:verify && rake features"
        end
      end
    end
    
  end
end
