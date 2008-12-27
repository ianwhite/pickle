require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Config do
  before do
    # zero pickle config before each example
    [:names, :model_names, :factory_names, :mappings].each do |config_var|
      instance_variable_set "@orig_#{config_var}", Pickle::Config.send(config_var)
      Pickle::Config.send("#{config_var}=", nil)
    end
  end
  
  after do
    # restore pickle config back after each example
    [:model_names, :factory_names, :names, :mappings].each do |config_var|
      Pickle::Config.send "#{config_var}=", instance_variable_get("@orig_#{config_var}")
    end
  end
  
  it ":factory_names should default to stringified keys of Factory.factories" do
    Factory.factories.should_receive(:keys).and_return([:one, :two])
    Pickle::Config.factory_names.should == ['one', 'two']
  end
  
  it ":model_names should default to directory listing of app/models excluding observers" do
    models_path = "#{RAILS_ROOT}/app/models"
    Dir.should_receive(:[]).with("#{models_path}/**/*.rb").and_return([
      "#{models_path}/one.rb",
      "#{models_path}/one/a.rb",
      "#{models_path}/one/b.rb",
      "#{models_path}/one/b/i.rb",
      "#{models_path}/one_observer.rb",
      "#{models_path}/two.rb"
    ])
    Pickle::Config.model_names.should == ['one', 'one/a', 'one/b', 'one/b/i', 'two']
  end
  
  it ":names should default to set (Array) :factory and :model names" do
    Pickle::Config.factory_names = ['one', 'two']
    Pickle::Config.model_names = ['two', 'one/a', 'one/b']
    Pickle::Config.names.sort.should == ['one', 'one/a', 'one/b', 'two']
  end
  
  it ":mappings should default to []" do
    Pickle::Config.mappings.should == []
  end
end