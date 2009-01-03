require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Adapter do
  it ".factories should raise NotImplementedError" do
    lambda{ Pickle::Adapter.factories }.should raise_error(NotImplementedError)
  end
  
  it "#create should raise NotImplementedError" do
    lambda{ Pickle::Adapter.new.create }.should raise_error(NotImplementedError)
  end
  
  it ".model_classes should not include CGI::Session::ActiveRecordStore" do
    Pickle::Adapter.model_classes.should_not include(CGI::Session::ActiveRecordStore)
  end
  
  describe '::ActiveRecord' do
    before do
      # set up a fake object space
      @klass1 = mock('One', :name => 'One')
      @klass2 = mock('One::Two', :name => 'One::Two')
      Pickle::Adapter::ActiveRecord.stub!(:model_classes).and_return([@klass1, @klass2])
    end
    
    describe ".factories" do
      it "should create one for each active record class" do
        Pickle::Adapter::ActiveRecord.should_receive(:new).with(@klass1).once
        Pickle::Adapter::ActiveRecord.should_receive(:new).with(@klass2).once
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
  end
  
  describe '::FactoryGirl' do
    before do
      # set up a fake object space
      @factory1 = mock('factory1', :factory_name => :one, :build_class => (@class1 = mock('Class1')))
      @factory2 = mock('factory2', :factory_name => :two, :build_class => (@class2 = mock('Class2')))
      Factory.stub!(:factories).and_return(:factory1 => @factory1, :factory2 => @factory2)
    end
    
    describe ".factories" do
      it "should create one for each factory" do
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
          @factory.klass.should == @class1
        end
        
        it "#create(attrs) should call Factory(<:key>, attrs)" do
          Factory.should_receive(:create).with("one", {:key => "val"})
          @factory.create(:key => "val")
        end
      end
    end
  end
  
  describe '::Machinist' do
    before do
      # set up a fake object space
      @klass1 = mock('One', :name => 'One', :make => true, :make_unsaved => true)
      @klass1.instance_variable_set('@blueprint', true)
      @klass2 = mock('Two', :name => 'Two')
      @klass3 = mock('Two::Sub', :name => 'Two::Sub', :make_special => true, :make => true, :make_unsaved => true)
      @klass3.instance_variable_set('@blueprint', true)
      Pickle::Adapter::Machinist.stub!(:model_classes).and_return([@klass1, @klass2, @klass3])
    end
    
    describe ".factories" do
      it "should create one for each machinist make method, except make_unsaved" do
        Pickle::Adapter::Machinist.should_receive(:new).with(@klass1, 'make').once
        Pickle::Adapter::Machinist.should_receive(:new).with(@klass3, 'make').once
        Pickle::Adapter::Machinist.should_receive(:new).with(@klass3, 'make_special').once
        Pickle::Adapter::Machinist.factories
      end
      
      describe ".new(Class, 'make')" do
        before do
          @factory = Pickle::Adapter::Machinist.new(@klass1, 'make')
        end
        
        it "should have underscored (s/_) name of Class as #name" do
          @factory.name.should == 'one'
        end
        
        it "#create(attrs) should call Class.make(attrs)" do
          @klass1.should_receive(:make).with({:key => "val"})
          @factory.create(:key => "val")
        end
      end
      
      describe ".new(Class, 'make_special')" do
        before do
          @factory = Pickle::Adapter::Machinist.new(@klass3, 'make_special')
        end
        
        it "should have 'special_<Class name>' as #name" do
          @factory.name.should == 'special_two_sub'
        end
        
        it "#create(attrs) should call Class.make_special(attrs)" do
          @klass3.should_receive(:make_special).with({:key => "val"})
          @factory.create(:key => "val")
        end
      end
    end
  end
end