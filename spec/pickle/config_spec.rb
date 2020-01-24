# typed: true
require 'spec_helper'

describe Pickle::Config do
  before do
    @config = Pickle::Config.new
  end

  it "#adapters should default to :machinist, :factory_bot, :orm" do
    expect(@config.adapters).to eq([:machinist, :factory_bot, :fabrication, :orm])
  end

  it "#adapter_classes should default to Adapter::Machinist, Adapter::FactoryBot, Adapter::Orm" do
    expect(@config.adapter_classes).to eq([Pickle::Adapter::Machinist, Pickle::Adapter::FactoryBot, Pickle::Adapter::Fabrication, Pickle::Adapter::Orm])
  end

  describe "setting adapters to [:machinist, SomeAdapter]" do
    class SomeAdapter; end

    before do
      @config.adapters = [:machinist, SomeAdapter]
    end

    it "#adapter_classes should be Adapter::Machinist, SomeAdapter" do
      expect(@config.adapter_classes).to eq([Pickle::Adapter::Machinist, SomeAdapter])
    end
  end

  describe "#factories" do
    it "should call adaptor.factories for each adaptor" do
      expect(Pickle::Adapter::Machinist).to receive(:factories).and_return([])
      expect(Pickle::Adapter::FactoryBot).to receive(:factories).and_return([])
      expect(Pickle::Adapter::Fabrication).to receive(:factories).and_return([])
      expect(Pickle::Adapter::Orm).to receive(:factories).and_return([])
      @config.factories
    end

    it "should aggregate factories into a hash using factory name as key" do
      expect(Pickle::Adapter::Machinist).to receive(:factories).and_return([@machinist = double('machinist', :name => 'machinist')])
      expect(Pickle::Adapter::FactoryBot).to receive(:factories).and_return([@factory_bot = double('factory_bot', :name => 'factory_bot')])
      expect(Pickle::Adapter::Fabrication).to receive(:factories).and_return([@fabrication = double('fabrication', :name => 'fabrication')])
      expect(Pickle::Adapter::Orm).to receive(:factories).and_return([@orm = double('orm', :name => 'orm')])
      expect(@config.factories).to eq({'machinist' => @machinist, 'factory_bot' => @factory_bot, 'fabrication' => @fabrication, 'orm' => @orm})
    end

    it "should give preference to adaptors first in the list" do
      expect(Pickle::Adapter::Machinist).to receive(:factories).and_return([@machinist_one = double('one', :name => 'one')])
      expect(Pickle::Adapter::FactoryBot).to receive(:factories).and_return([@factory_bot_one = double('one', :name => 'one'), @factory_bot_two = double('two', :name => 'two')])
      expect(Pickle::Adapter::Fabrication).to receive(:factories).and_return([@fabrication_one = double('one', :name => 'one'), @fabrication_three = double('three', :name => 'three')])
      expect(Pickle::Adapter::Orm).to receive(:factories).and_return([@orm_two = double('two', :name => 'two'), @orm_four = double('four', :name => 'four')])
      expect(@config.factories).to eq({'one' => @machinist_one, 'two' => @factory_bot_two, 'three' => @fabrication_three, 'four' => @orm_four})
    end
  end

  it "#mappings should default to []" do
    expect(@config.mappings).to eq([])
  end

  describe '#predicates' do
    it "should be list of all non object ? public instance methods + columns methods of Adapter.model_classes" do
      class1 = double('Class1',
                    :public_instance_methods => ['nope', 'foo?', 'bar?'],
                    :column_names => ['one', 'two'],
                    :const_get => ::ActiveRecord::Base::PickleAdapter
      )
      class2 = double('Class2',
                    :public_instance_methods => ['not', 'foo?', 'faz?'],
                    :column_names => ['two', 'three'],
                    :const_get => ::ActiveRecord::Base::PickleAdapter
      )
      allow(Pickle::Adapter).to receive(:model_classes).and_return([class1, class2])

      expect(@config.predicates.to_set).to eq(['foo?', 'faz?', 'bar?', 'one', 'two', 'three'].to_set)
    end

    it "should be overridable" do
      @config.predicates = %w(lame?)
      expect(@config.predicates).to eq(%w(lame?))
    end
  end

  describe "#map 'foo', :to => 'faz'" do
    before do
      @config.map 'foo', :to => 'faz'
    end

    it "should create Mapping('foo', 'faz') mapping" do
      @config.mappings.first.tap do |mapping|
        expect(mapping).to be_kind_of Pickle::Config::Mapping
        expect(mapping.search).to eq('foo')
        expect(mapping.replacement).to eq('faz')
      end
    end
  end

  describe "#map 'foo', 'bar' :to => 'faz'" do
    before do
      @config.map 'foo', 'bar', :to => 'faz'
    end

    it "should create 2 mappings" do
      expect(@config.mappings.first).to eq(Pickle::Config::Mapping.new('foo', 'faz'))
      expect(@config.mappings.last).to eq(Pickle::Config::Mapping.new('bar', 'faz'))
    end
  end

  it "#configure(&block) should execiute on self" do
    expect(@config).to receive(:foo).with(:bar)
    @config.configure do |c|
      c.foo :bar
    end
  end
end
