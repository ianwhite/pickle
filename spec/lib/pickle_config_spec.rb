require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Config do
  before do
    # zero pickle config before each example
    [:names, :model_names, :blueprint_names, :factory_names, :mappings].each do |config_var|
      instance_variable_set "@orig_#{config_var}", Pickle::Config.send(config_var)
      Pickle::Config.send("#{config_var}=", nil)
    end
  end
  
  after do
    # restore pickle config back after each example
    [:model_names, :factory_names, :blueprint_names, :names, :mappings].each do |config_var|
      Pickle::Config.send "#{config_var}=", instance_variable_get("@orig_#{config_var}")
    end
  end
  
  it "#names should default to set of (Array) #blueprint, #factory, and #model names" do
    Pickle::Config.blueprint_names = ['one', 'two_a']
    Pickle::Config.factory_names = ['one', 'two']
    Pickle::Config.model_names = ['two', 'one/a', 'one/b']
    Pickle::Config.names.sort.should == ['one', 'one/a', 'one/b', 'two', 'two_a']
  end
  
  it "#mappings should default to []" do
    Pickle::Config.mappings.should == []
  end
end