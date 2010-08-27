require 'aruba'

Given /I create an (example \w[\w ]+ app)$/ do |app|
  steps %Q{
    Given I create an empty #{app}
    Given I create a database setup for the #{app}
    Given I create an #{app} user model     
    Given I create an #{app} note model
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
    require 'user'
    require 'note'
  FILE
end

Given /I am writing a test using the pickle dsl/ do 
  @test = <<-FILE
    require 'app'
    require 'factory'
    require 'spec/expectations'
  
    require 'pickle'
    require 'pickle/orm_adapters/autoload'
  
    include Pickle::Dsl
    include Spec::Matchers
  FILE
end

Given /notice the code is the same even though the orm is (\w+) and the factory is (\w+)/ do |orm, factory|
  announce "\n\n**\n** Commence test using orm: #{orm} with factory: #{factory}\n**\n"
end

Then /^(.*) \(code\):$/ do |intention, code|
  @test += "\n" + code
  create_file 'test.rb', @test
  announce "\n#{intention} (code):\n#{code}\n"
  run("ruby test.rb")
end