require 'aruba'

Given /I create an (example \w[\w ]+ app)$/ do |app|
  steps %Q{
    Given I create an empty #{app}
    Given I create a database setup for the #{app}
    Given I create the #{app} models
  }
end

Given /^I create an empty ([\w ]+ app)$/ do |app|
  app_path = app.gsub(/\W/,' ').squish.gsub(' ','_')
  steps %Q{
    Given a directory named "#{app_path}"
    Given I cd to "#{app_path}"
    Given pickle's libs are symlinked to "lib"
    Given I create the "app.rb" file
  }
end

Given /pickle's libs are symlinked to "lib"/ do
  steps %q{
    Given a directory named "lib"
  }
  pickle_lib = File.expand_path(File.join(File.dirname(__FILE__), '../../lib'))
  in_current_dir do
    `ln -s #{pickle_lib}/pickle.rb lib/pickle.rb`
    `ln -s #{pickle_lib}/pickle lib/pickle`
  end
end

Given /I create the "app.rb" file/ do
  create_file "app.rb", <<-FILE
    require 'rubygems'
    $:.unshift 'lib'
    require 'db'
    require 'models'
  FILE
end

Given /^I am writing features using pickle, (\w+) \((\w+)\) and the following config:$/ do |factory, orm, config|
  create_dir 'features'
  create_dir 'features/step_definitions'
  create_dir 'features/support'
  
  create_file 'features/support/env.rb', <<-FILE
    #{"require 'rubygems'; require 'machinist/mongoid'\n" if factory == 'machinist' && orm == 'mongoid'}
    require 'app'
    require 'factory'
    require 'spec/expectations'
    require 'pickle/cucumber'
    
    #{config}
  FILE
  
  templates_dir = File.expand_path(File.join(File.dirname(__FILE__), '../../templates'))
  in_current_dir do
    `ln -s #{templates_dir}/pickle/pickle_steps.rb features/step_definitions/pickle_steps.rb`
  end
end

Given /the following "([^"]*)" test using the pickle dsl, with (\w+) \((\w+)\):/ do |file, factory, orm, code|
  create_file "#{file}_test.rb", <<-FILE
    #{"require 'rubygems'; require 'machinist/mongoid'\n" if factory == 'machinist' && orm == 'mongoid'}

    require 'app'
    require 'factory'
    require 'spec/expectations'
  
    require 'pickle'
    require 'pickle/orm_adapters/autoload'
  
    include Pickle::Dsl
    include Spec::Matchers
    
    #{code}
  FILE
end

Given /^a feature "([^"]*)" with:$/ do |feature, string|
  create_file "features/#{feature}.feature", string
end

Then /^running the "([^"]*)" test should pass$/ do |test|
  run "ruby #{test}_test.rb"
end

Then /^running the "([^"]*)" feature should pass$/ do |feature|
  run "cucumber features/#{feature}.feature"
  combined_output.should =~ /(\d+) scenarios? \(\1 passed\)/
end