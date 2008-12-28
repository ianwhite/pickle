require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Config do
  before do
    # zero pickle config before each example
    [:adapters, :factories, :names, :mappings].each do |config_var|
      instance_variable_set "@orig_#{config_var}", Pickle::Config.send(config_var)
      Pickle::Config.instance_variable_set("@#{config_var}", nil)
    end
  end
  
  after do
    # restore pickle config back after each example
    [:adapters, :factories, :names, :mappings].each do |config_var|
      Pickle::Config.instance_variable_set("@#{config_var}", instance_variable_get("@orig_#{config_var}"))
    end
  end
  
  it ".adapters should default to Machinist, FactoryGirl, ActiveRecord" do
    Pickle::Config.adapters.should == [Pickle::Adapter::Machinist, Pickle::Adapter::FactoryGirl, Pickle::Adapter::ActiveRecord]
  end
  
  describe ".factories" do
    it "should call adaptor.factories for each adaptor" do
      Pickle::Adapter::Machinist.should_receive(:factories).and_return([])
      Pickle::Adapter::FactoryGirl.should_receive(:factories).and_return([])
      Pickle::Adapter::ActiveRecord.should_receive(:factories).and_return([])
      Pickle::Config.factories
    end
    
    it "should aggregate factories into a hash using factory name as key" do
      Pickle::Adapter::Machinist.should_receive(:factories).and_return([@machinist = mock('machinist', :name => 'machinist')])
      Pickle::Adapter::FactoryGirl.should_receive(:factories).and_return([@factory_girl = mock('factory_girl', :name => 'factory_girl')])
      Pickle::Adapter::ActiveRecord.should_receive(:factories).and_return([@active_record = mock('active_record', :name => 'active_record')])
      Pickle::Config.factories.should == {'machinist' => @machinist, 'factory_girl' => @factory_girl, 'active_record' => @active_record}
    end
    
    it "should give preference to adaptors first in the list" do
      Pickle::Adapter::Machinist.should_receive(:factories).and_return([@machinist_one = mock('one', :name => 'one')])
      Pickle::Adapter::FactoryGirl.should_receive(:factories).and_return([@factory_girl_one = mock('one', :name => 'one'), @factory_girl_two = mock('two', :name => 'two')])
      Pickle::Adapter::ActiveRecord.should_receive(:factories).and_return([@active_record_two = mock('two', :name => 'two'), @active_record_three = mock('three', :name => 'three')])
      Pickle::Config.factories.should == {'one' => @machinist_one, 'two' => @factory_girl_two, 'three' => @active_record_three}
    end
  end
  
  it ".names should be keys of .factories" do
    Pickle::Config.should_receive(:factories).and_return('one' => nil, 'two' => nil)
    Pickle::Config.names.should == ['one', 'two']
  end
  
  it ".mappings should default to []" do
    Pickle::Config.mappings.should == []
  end
end