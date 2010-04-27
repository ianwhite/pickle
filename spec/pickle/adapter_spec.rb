require File.dirname(__FILE__) + '/../spec_helper'

require 'active_record'
require 'factory_girl'
require 'machinist/active_record'

describe Pickle::Adapter do
  it ".factories should raise NotImplementedError" do
    lambda{ Pickle::Adapter.factories }.should raise_error(NotImplementedError)
  end
  
  it "#create should raise NotImplementedError" do
    lambda{ Pickle::Adapter.new.create }.should raise_error(NotImplementedError)
  end
  
  describe ".suitable_for_pickle?(klass)" do
    let :klass do
      mock('Class', :abstract_class? => false, :table_exists? => true)
    end
    
    before do
      Pickle::Adapter.stub!(:framework_class?).and_return(false)
    end
    
    it "a non abstract class that has a table, and is not a framework class, is suitable_for_pickle" do
      Pickle::Adapter.should be_suitable_for_pickle(klass)
    end
    
    it "an abtract_class is not suitable_for_pickle" do
      klass.stub!(:abstract_class?).and_return(true)
      Pickle::Adapter.should_not be_suitable_for_pickle(klass)
    end
    
    it "a class with no table is not suitable_for_pickle" do
      klass.stub!(:table_exists?).and_return(false)
      Pickle::Adapter.should_not be_suitable_for_pickle(klass)
    end
    
    it "an frame_work class is not suitable_for_pickle" do
      Pickle::Adapter.should_receive(:framework_class?).with(klass).and_return(true)
      Pickle::Adapter.should_not be_suitable_for_pickle(klass)
    end
  end
  
  describe ".model_classes" do
    before do
      Pickle::Adapter.model_classes = nil
    end
    
    it "should only include #suitable_for_pickle classes" do
      klass1 = Class.new(ActiveRecord::Base)
      klass2 = Class.new(ActiveRecord::Base)
      Pickle::Adapter.should_receive(:suitable_for_pickle?).with(klass1).and_return(true)
      Pickle::Adapter.should_receive(:suitable_for_pickle?).with(klass2).and_return(false)
      Pickle::Adapter.model_classes.should include(klass1)
      Pickle::Adapter.model_classes.should_not include(klass2)
    end
  end
  
  describe "adapters: " do
    before do
      @klass1 = returning(Class.new(ActiveRecord::Base)) {|k| k.stub!(:name).and_return('One')}
      @klass2 = returning(Class.new(ActiveRecord::Base)) {|k| k.stub!(:name).and_return('One::Two')}
      @klass3 = returning(Class.new(ActiveRecord::Base)) {|k| k.stub!(:name).and_return('Three')}
    end
    
    describe 'ActiveRecord' do
      before do
        Pickle::Adapter::ActiveRecord.stub!(:model_classes).and_return([@klass1, @klass2, @klass3])
      end
      
      it ".factories should create one for each active record class" do
        Pickle::Adapter::ActiveRecord.should_receive(:new).with(@klass1).once
        Pickle::Adapter::ActiveRecord.should_receive(:new).with(@klass2).once
        Pickle::Adapter::ActiveRecord.should_receive(:new).with(@klass3).once
        Pickle::Adapter::ActiveRecord.factories
      end
      
      describe ".new(Class)" do
        before do
          @factory = Pickle::Adapter::ActiveRecord.new(@klass2)
        end
      
        it "should have underscored (s/_) name of Class as #name" do
          @factory.name.should == 'one_two'
        end
      
        it "#create(attrs) should call Class.create!(attrs)" do
          @klass2.should_receive(:create!).with({:key => "val"})
          @factory.create(:key => "val")
        end
      end
    end
  
    describe 'FactoryGirl' do
      before do
        Pickle::Adapter::FactoryGirl.stub!(:model_classes).and_return([@klass1, @klass2, @klass3])
        @orig_factories, Factory.factories = Factory.factories, {}
        
        Factory.define(:one, :class => @klass1) {}
        Factory.define(:two, :class => @klass2) {}
        @factory1 = Factory.factories[:one]
        @factory2 = Factory.factories[:two]
      end
      
      after do
        Factory.factories = @orig_factories
      end
    
      it ".factories should create one for each factory" do
        Pickle::Adapter::FactoryGirl.should_receive(:new).with(@factory1).once
        Pickle::Adapter::FactoryGirl.should_receive(:new).with(@factory2).once
        Pickle::Adapter::FactoryGirl.factories
      end
    
      describe ".new(factory)" do
        before do
          @factory = Pickle::Adapter::FactoryGirl.new(@factory1)
        end
      
        it "should have name of factory_name" do
          @factory.name.should == 'one'
        end
      
        it "should have klass of build_class" do
          @factory.klass.should == @klass1
        end
      
        it "#create(attrs) should call Factory(<:key>, attrs)" do
          Factory.should_receive(:create).with("one", {:key => "val"})
          @factory.create(:key => "val")
        end
      end
    end
  
    describe 'Machinist' do
      before do
        Pickle::Adapter::Machinist.stub!(:model_classes).and_return([@klass1, @klass2, @klass3])
        
        @klass1.blueprint {}
        @klass3.blueprint {}
        @klass3.blueprint(:special) {}
      end
      
      it ".factories should create one for each master blueprint, and special case" do
        Pickle::Adapter::Machinist.should_receive(:new).with(@klass1, :master).once
        Pickle::Adapter::Machinist.should_receive(:new).with(@klass3, :master).once
        Pickle::Adapter::Machinist.should_receive(:new).with(@klass3, :special).once
        Pickle::Adapter::Machinist.factories
      end
        
      describe ".new(Class, :master)" do
        before do
          @factory = Pickle::Adapter::Machinist.new(@klass1, :master)
        end
        
        it "should have underscored (s/_) name of Class as #name" do
          @factory.name.should == 'one'
        end
        
        it "#create(attrs) should call Class.make(:master, attrs)" do
          @klass1.should_receive(:make).with(:master, {:key => "val"})
          @factory.create(:key => "val")
        end
      end
      
      describe ".new(Class, :special)" do
        before do
          @factory = Pickle::Adapter::Machinist.new(@klass3, :special)
        end
        
        it "should have 'special_<Class name>' as #name" do
          @factory.name.should == 'special_three'
        end
        
        it "#create(attrs) should call Class.make(:special, attrs)" do
          @klass3.should_receive(:make).with(:special, {:key => "val"})
          @factory.create(:key => "val")
        end
      end
    end
  end
end