require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require 'pickle/config'

describe Pickle::Config do
  before do
    @config = Pickle::Config.new
  end
  
  it "#adapters should default to :machinist, :factory_girl, :active_record" do
    @config.adapters.should == [:machinist, :factory_girl, :active_record]
  end
  
  it "#adapter_classes should default to Adapter::Machinist, Adapter::FactoryGirl, Adapter::ActiveRecord" do
    @config.adapter_classes.should == [Pickle::Adapter::Machinist, Pickle::Adapter::FactoryGirl, Pickle::Adapter::ActiveRecord]
  end
  
  describe "setting adapters to [:machinist, SomeAdapter]" do
    class SomeAdapter; end
    
    before do
      @config.adapters = [:machinist, SomeAdapter]
    end
    
    it "#adapter_classes should be Adapter::Machinist, SomeAdapter" do
      @config.adapter_classes.should == [Pickle::Adapter::Machinist, SomeAdapter]
    end
  end
  
  describe "#factories" do
    it "should call adaptor.factories for each adaptor" do
      Pickle::Adapter::Machinist.should_receive(:factories).and_return([])
      Pickle::Adapter::FactoryGirl.should_receive(:factories).and_return([])
      Pickle::Adapter::ActiveRecord.should_receive(:factories).and_return([])
      @config.factories
    end
    
    it "should aggregate factories into a hash using factory name as key" do
      Pickle::Adapter::Machinist.should_receive(:factories).and_return([@machinist = mock('machinist', :name => 'machinist')])
      Pickle::Adapter::FactoryGirl.should_receive(:factories).and_return([@factory_girl = mock('factory_girl', :name => 'factory_girl')])
      Pickle::Adapter::ActiveRecord.should_receive(:factories).and_return([@active_record = mock('active_record', :name => 'active_record')])
      @config.factories.should == {'machinist' => @machinist, 'factory_girl' => @factory_girl, 'active_record' => @active_record}
    end
    
    it "should give preference to adaptors first in the list" do
      Pickle::Adapter::Machinist.should_receive(:factories).and_return([@machinist_one = mock('one', :name => 'one')])
      Pickle::Adapter::FactoryGirl.should_receive(:factories).and_return([@factory_girl_one = mock('one', :name => 'one'), @factory_girl_two = mock('two', :name => 'two')])
      Pickle::Adapter::ActiveRecord.should_receive(:factories).and_return([@active_record_two = mock('two', :name => 'two'), @active_record_three = mock('three', :name => 'three')])
      @config.factories.should == {'one' => @machinist_one, 'two' => @factory_girl_two, 'three' => @active_record_three}
    end
  end
  
  it "#names should be keys of .factories" do
    @config.should_receive(:factories).and_return('one' => nil, 'two' => nil)
    @config.names.should == ['one', 'two']
  end
  
  it "#mappings should default to []" do
    @config.mappings.should == []
  end

  it "#map 'foo', :to => 'faz', should create {:search => 'foo', :replace => 'faz'} mapping" do
    @config.map 'foo', :to => 'faz'
    @config.mappings.first.should == {:search => 'foo', :replace => 'faz'}
  end
  
  it "#map 'foo', 'bar' :to => 'faz', should create {:search => '(?:foo|bar)', :replace => 'faz'} mapping" do
    @config.map 'foo', 'bar', :to => 'faz'
    @config.mappings.first.should == {:search => '(?:foo|bar)', :replace => 'faz'}
  end
  
  describe ".default (class method)" do
    it "should refer to same object" do
      Pickle::Config.default.should == Pickle::Config.default
    end
    
    it "called with (&block) should execute on the config" do
      Pickle::Config.default.should_receive(:foo).with(:bar)
      Pickle::Config.default do |c|
        c.foo :bar
      end
    end
  end
end