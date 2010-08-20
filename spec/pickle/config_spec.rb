require 'spec_helper'

describe Pickle::Config do
  subject { Pickle::Config.new }
  
  describe "new" do
    its(:adapters) { should == [:machinist, :factory_girl, :orm] }
    its(:adapter_classes) { should == [Pickle::Adapter::Machinist, Pickle::Adapter::FactoryGirl, Pickle::Adapter::Orm] }
    its(:predicates) { should be_empty }
    its(:mappings) { should be_empty }
    its(:factories) { should be_empty }
    its(:plural_factories) { should be_empty }
    its(:aliases) { should be_empty }
    its(:labels) { should be_empty }
  end

  describe "setting adapters to [:machinist, <adapter_class>]" do
    let(:adapter_class) { Class.new(Object) }

    before { subject.adapters = [:machinist, adapter_class] }
    
    it "should have :adapter_classes [Pickle::Adapter::Machinist, <adapter_class>]" do
      subject.adapter_classes.should == [Pickle::Adapter::Machinist, adapter_class]
    end
  end

  describe "#map 'foo', :to => 'faz'" do
    before { subject.map 'foo', :to => 'faz' }

    it "should create Mapping('foo', 'faz') mapping" do
      subject.mappings.first.tap do |mapping|
        mapping.should be_kind_of Pickle::Config::Mapping
        mapping.search.should == 'foo'
        mapping.replacement.should == 'faz'
      end
    end
  end

  describe "#map 'foo', 'bar' :to => 'faz'" do
    before { subject.map 'foo', 'bar', :to => 'faz' }

    it "should create 2 mappings" do
      subject.mappings.first.should == Pickle::Config::Mapping.new('foo', 'faz')
      subject.mappings.last.should == Pickle::Config::Mapping.new('bar', 'faz')
    end
  end

  it "#configure(&block) should execiute on self" do
    subject.should_receive(:foo).with(:bar)
    subject.configure do |c|
      c.foo :bar
    end
  end
end
