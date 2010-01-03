garlic do
  repo 'rails', :url => 'git://github.com/rails/rails'
  repo 'rspec', :url => 'git://github.com/dchelimsky/rspec'
  repo 'rspec-rails', :url => 'git://github.com/dchelimsky/rspec-rails'
  repo 'factory_girl', :url => 'git://github.com/thoughtbot/factory_girl'
  repo 'machinist', :url => 'git://github.com/notahat/machinist'
  repo 'cucumber', :url => 'git://github.com/aslakhellesoy/cucumber'
  repo 'cucumber-rails', :url => 'git://github.com/aslakhellesoy/cucumber-rails'
  repo 'webrat', :url => 'git://github.com/brynary/webrat'
  repo 'pickle', :path => '.'

  ['2-3-stable', '2-2-stable', '2-1-stable'].each do |rails|
  
    target rails, :tree_ish => "origin/#{rails}" do
      prepare do
        plugin 'pickle', :clone => true
        plugin 'rspec'
        plugin 'rspec-rails' do
          `script/generate rspec -f`
        end
        plugin 'factory_girl'
        plugin 'cucumber'
        plugin 'machinist'
        plugin 'webrat'
        plugin 'cucumber-rails' do
          `script/generate cucumber --webrat -f`
        end
      end
  
      run do
        cd "vendor/plugins/pickle" do
          sh "rake rcov:verify && rake features"
        end
      end
    end
    
  end
end
