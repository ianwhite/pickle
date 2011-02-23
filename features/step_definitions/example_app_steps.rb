Given /an example (\w+)\/(\w+) app/ do |orm, factory| 
  steps %Q{
    Given I create an empty example #{orm} app
    Given I create a database setup for the example #{orm} app
    Given I create the example #{orm} app models
    And I am using #{factory} (#{orm}) for generating test data
    And cucumber is setup for pickle with the example #{orm}/#{factory} app
    And a spec helper is setup including the pickle dsl with the example #{orm}/#{factory} app
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
  create_dir "lib"
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

Given /^cucumber is setup for pickle with the example (\w+)\/(\w+) app$/ do |orm, factory|
  create_dir 'features'
  create_dir 'features/step_definitions'
  create_dir 'features/support'
  
  create_file 'features/support/env.rb', <<-FILE
    #{"require 'rubygems'; require 'machinist/mongoid'\n" if factory == 'machinist' && orm == 'mongoid'}
    require 'app'
    require 'factory'
    require 'rspec/expectations'
    require 'pickle/cucumber'
  FILE
  
  templates_dir = File.expand_path(File.join(File.dirname(__FILE__), '../../templates'))
  in_current_dir do
    `ln -s #{templates_dir}/pickle/pickle_steps.rb features/step_definitions/pickle_steps.rb`
  end
end

Given /^a spec helper is setup including the pickle dsl with the example (\w+)\/(\w+) app$/ do |orm, factory|
  create_file "spec_helper.rb", <<-FILE
    #{"require 'rubygems'; require 'machinist/mongoid'\n" if factory == 'machinist' && orm == 'mongoid'}

    require 'app'
    require 'factory'
    require 'rspec/expectations'
  
    require 'pickle'
    
    include Pickle::Dsl
    include Spec::Matchers
  FILE
end

Given /^a pickle config:$/ do |content|
  create_file "features/support/pickle_config.rb", content
end

Given /^(?:a )?step definitions?:$/ do |content|
  create_step_definition content
end

Then /^the following steps should pass:$/ do |steps|
  run_feature create_feature("Feature:\nScenario:\n#{steps}")
end

Then /^the following spec should pass:$/ do |test|
  run_spec create_spec(test)
end

module ExampleAppHelper
  def create_step_definition(content)
    @step_def_files ||= 0
    create_file "features/step_definitions/step_def_#{@step_def_files += 1}_steps.rb", content
  end
  
  def create_feature(content)
    @feature_files ||= 0
    feature_name = "feature_#{@feature_files += 1}"
    create_file "features/#{feature_name}.feature", content
    feature_name
  end
  
  def create_spec(code)
    @test_files ||= 0
    test_name = "test_#{@test_files += 1}"
    create_file "#{test_name}_spec.rb", "require 'spec_helper'\n#{code}"
    test_name
  end
  
  def run_feature(feature)
    run "cucumber features/#{feature}.feature"
    all_output =~ /(\d+) scenarios? \(\1 passed\)/ or raise "Following steps did not pass:\n\n#{all_output}"
  end
  
  def run_spec(test)
    run "ruby #{test}_spec.rb"
  end
end

World(ExampleAppHelper)