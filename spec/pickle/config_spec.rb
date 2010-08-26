require 'spec_helper'

describe Pickle::Config do
  subject { Pickle::Config.new }

  describe "new" do
    its(:adapters) { should == [:machinist, :factory_girl, :orm] }
    its(:adapter_classes) { should == [Pickle::Adapter::Machinist, Pickle::Adapter::FactoryGirl, Pickle::Adapter::Orm] }
    its(:predicates) { should be_empty }
    its(:mappings) { should be_empty }
    its(:factories) { should be_empty }
    its(:aliases) { should be_empty }
    its(:label_map) { should be_empty }
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

  describe "map_label_for" do
    let(:config) {Pickle::Config.new}
    subject { config }

    describe "'user', :to => 'name'" do
      before { config.map_label_for('user', :to => 'name') }
      its(:label_map) {should include('user' => 'name')}
    end

    describe "'user', 'admin', 'supplier', :to => 'name'" do
      before { config.map_label_for 'user','admin','supplier', :to => 'name' }
      its(:label_map) {should include('user' => 'name')}
      its(:label_map) {should include('admin' => 'name')}
      its(:label_map) {should include('supplier' => 'name')}            
    end
  end

  describe "alias" do
    let(:config) {Pickle::Config.new}
    subject { config }

    describe "user, :to => 'name'" do
      before { config.alias('admin', :to => 'admin user') }
      its(:aliases) {should include('admin' => 'admin user')}
    end

    describe "customer, supplier, reseller :to => 'trade user'" do
      before { config.alias 'customer','supplier','reseller', :to => 'trade user' }
      its(:aliases) {should include('customer' => 'trade user')}
      its(:aliases) {should include('supplier' => 'trade user')}
      its(:aliases) {should include('reseller' => 'trade user')}            
    end
  end
end
