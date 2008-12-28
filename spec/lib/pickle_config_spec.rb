require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Config do
  before do
    # zero pickle config before each example
    [:adapters, :factories, :mappings].each do |config_var|
      instance_variable_set "@orig_#{config_var}", Pickle::Config.send(config_var)
      Pickle::Config.send("#{config_var}=", nil)
    end
  end
  
  after do
    # restore pickle config back after each example
    [:adapters, :factories, :mappings].each do |config_var|
      Pickle::Config.send "#{config_var}=", instance_variable_get("@orig_#{config_var}")
    end
  end
  
  it ".adapters should default to Machinist, FactoryGirl, ActiveRecord" do
    Pickle::Config.adapters.should == [Pickle::Adapter::Machinist, Pickle::Adapter::FactoryGirl, Pickle::Adapter::ActiveRecord]
  end
  
  describe ".factories" do
    it "should call adaptor.factories for each adaptor" do
      Pickle::Adaptor::Machinist.should_receive(:factories).and_return([])
      Pickle::Adaptor::FactoryGirl.should_receive(:factories).and_return([])
      Pickle::Adaptor::ActiveRecord.should_receive(:factories).and_return([])
      Pickle::Config.factories
    end
    
    it "should aggregate factories into a hash using factory name as key" do
      Pickle::Adaptor::Machinist.should_receive(:factories).and_return([@machinist = mock(:name => 'machinist')])
      Pickle::Adaptor::FactoryGirl.should_receive(:factories).and_return([@factory_girl = mock(:name => 'factory_girl')])
      Pickle::Adaptor::ActiveRecord.should_receive(:factories).and_return([@active_record = mock(:name => 'active_record')])
      Pickle::Config.factories.should == {'machinist' => @machinist, 'factory_girl' => @factory_girl, 'active_record' => @active_record}
    end
    
    it "should give preference to adaptors first in the list" do
      Pickle::Adaptor::Machinist.should_receive(:factories).and_return([@machinist_one = mock(:name => 'one')])
      Pickle::Adaptor::FactoryGirl.should_receive(:factories).and_return([@factory_girl_one = mock(:name => 'one'), @factory_girl_two = mock(:name => 'two')])
      Pickle::Adaptor::ActiveRecord.should_receive(:factories).and_return([@active_record_two = mock(:name => 'two'), @active_record_three = mock(:name => 'three')])
      Pickle::Config.factories.should == {'one' => @machinist_one, 'two' => @factory_girl_two, 'three' => @active_record_three}
    end
  end
  
  it ".names should be keys of .factories" do
    Pickle::Config.stub!(:factories).and_return('one' => nil, 'two' => nil)
    Pickle::Config.names.should == ['one', 'two']
  end
  
  it ".mappings should default to []" do
    Pickle::Config.mappings.should == []
  end
end