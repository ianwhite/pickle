require 'spec_helper'

describe Pickle::Config do
  before do
    @config = Pickle::Config.new
  end

  it "#adapters should default to :machinist, :factory_girl, :orm" do
    @config.adapters.should == [:machinist, :factory_girl, :orm]
  end

  it "#adapter_classes should default to Adapter::Machinist, Adapter::FactoryGirl, Adapter::Orm" do
    @config.adapter_classes.should == [Pickle::Adapter::Machinist, Pickle::Adapter::FactoryGirl, Pickle::Adapter::Orm]
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
      Pickle::Adapter::Orm.should_receive(:factories).and_return([])
      @config.factories
    end

    it "should aggregate factories into a hash using factory name as key" do
      Pickle::Adapter::Machinist.should_receive(:factories).and_return([@machinist = mock('machinist', :name => 'machinist')])
      Pickle::Adapter::FactoryGirl.should_receive(:factories).and_return([@factory_girl = mock('factory_girl', :name => 'factory_girl')])
      Pickle::Adapter::Orm.should_receive(:factories).and_return([@orm = mock('orm', :name => 'orm')])
      @config.factories.should == {'machinist' => @machinist, 'factory_girl' => @factory_girl, 'orm' => @orm}
    end

    it "should give preference to adaptors first in the list" do
      Pickle::Adapter::Machinist.should_receive(:factories).and_return([@machinist_one = mock('one', :name => 'one')])
      Pickle::Adapter::FactoryGirl.should_receive(:factories).and_return([@factory_girl_one = mock('one', :name => 'one'), @factory_girl_two = mock('two', :name => 'two')])
      Pickle::Adapter::Orm.should_receive(:factories).and_return([@orm_two = mock('two', :name => 'two'), @orm_three = mock('three', :name => 'three')])
      @config.factories.should == {'one' => @machinist_one, 'two' => @factory_girl_two, 'three' => @orm_three}
    end
  end

  it "#mappings should default to []" do
    @config.mappings.should == []
  end

  describe '#predicates' do
    it "should be list of all non object ? public instance methods + columns methods of Adapter.model_classes" do
      class1 = mock('Class1',
                    :public_instance_methods => ['nope', 'foo?', 'bar?'],
                    :column_names => ['one', 'two'],
                    :const_get => ::ActiveRecord::Base::PickleAdapter
      )
      class2 = mock('Class2',
                    :public_instance_methods => ['not', 'foo?', 'faz?'],
                    :column_names => ['two', 'three'],
                    :const_get => ::ActiveRecord::Base::PickleAdapter
      )
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

    it "should create Mapping('foo', 'faz') mapping" do
      @config.mappings.first.tap do |mapping|
        mapping.should be_kind_of Pickle::Config::Mapping
        mapping.search.should == 'foo'
        mapping.replacement.should == 'faz'
      end
    end
  end

  describe "#map 'foo', 'bar' :to => 'faz'" do
    before do
      @config.map 'foo', 'bar', :to => 'faz'
    end

    it "should create 2 mappings" do
      @config.mappings.first.should == Pickle::Config::Mapping.new('foo', 'faz')
      @config.mappings.last.should == Pickle::Config::Mapping.new('bar', 'faz')
    end
  end

  it "#configure(&block) should execiute on self" do
    @config.should_receive(:foo).with(:bar)
    @config.configure do |c|
      c.foo :bar
    end
  end
end
