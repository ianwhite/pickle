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

Given /I am writing a test using the pickle dsl, with (\w+) \((\w+)\)/ do |factory, orm|
  @code = ""
  
  # for some reason to do with mongoid & machinist combo, the following line needs to be first
  @code += "require 'rubygems'; require 'machinist/mongoid'\n" if factory == 'machinist' && orm == 'mongoid'

  @code += <<-FILE
    require 'app'
    require 'factory'
    require 'spec/expectations'
  
    require 'pickle'
    require 'pickle/orm_adapters/autoload'
  
    include Pickle::Dsl
    include Spec::Matchers
  FILE
  announce "\n\n**\n** testing using orm: #{orm} with factory: #{factory}\n**\n" if @anncounce_code
end

Then /^(.*) \(code\):$/ do |intention, code|
  announce "\n# #{intention}\n#{code}\n" if @anncounce_code
  $stdout.flush
  @code += "\n# #{intention}\n#{code}\n"
  create_file 'code.rb', @code
  run("ruby code.rb")
end