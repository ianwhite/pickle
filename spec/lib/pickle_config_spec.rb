require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

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
  
  it "#mappings should default to []" do
    @config.mappings.should == []
  end

  describe '#predicates' do
    it "should be list of all non object ? public instance methods + columns methods of Adapter.model_classes" do
      class1 = mock('Class1', :public_instance_methods => ['nope', 'foo?', 'bar?'], :column_names => ['one', 'two'])
      class2 = mock('Class2', :public_instance_methods => ['not', 'foo?', 'faz?'], :column_names => ['two', 'three'])
      Pickle::Adapter.stub!(:model_classes).and_return([class1, class2])
      
      @config.predicates.to_set.should == ['foo?', 'faz?', 'bar?', 'one', 'two', 'three'].to_set
    end
    
    it "should be overridable" do
      @config.predicates = %w(lame?)
      @config.predicates.should == %w(lame?)
    end
  end
  
  describe "#map 'foo', :to => 'faz'" do
    before do
      @config.map 'foo', :to => 'faz'
    end
    
    it "should create OpenStruct(search: 'foo', replace: 'faz') mapping" do
      @config.mappings.first.should == OpenStruct.new(:search => 'foo', :replace => 'faz')
    end
  end
  
  describe "#map 'foo', 'bar' :to => 'faz'" do
    before do
      @config.map 'foo', 'bar', :to => 'faz'
    end
    
    it "should create 2 mappings" do
      @config.mappings.first.should == OpenStruct.new(:search => 'foo', :replace => 'faz')
      @config.mappings.last.should == OpenStruct.new(:search => 'bar', :replace => 'faz')
    end
  end
  
  it "#configure(&block) should execiute on self" do
    @config.should_receive(:foo).with(:bar)
    @config.configure do |c|
      c.foo :bar
    end
  end
end