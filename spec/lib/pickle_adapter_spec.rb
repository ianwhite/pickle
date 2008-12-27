require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Adapter do
  it ".factories should raise NotImplementedError" do
    lambda{ Pickle::Adapter.factories }.should raise_error(NotImplementedError)
  end
  
  it "#create should raise NotImplementedError" do
    lambda{ Pickle::Adapter.new.create }.should raise_error(NotImplementedError)
  end
  
  describe 'Machinist' do
    before do
      # set up a fake object space
      @klass1 = mock('One', :name => 'One', :make => true)
      @klass2 = mock('Two', :name => 'Two')
      @klass3 = mock ('Three', :name => 'Three', :make_special => true, :make => true)
      ::ActiveRecord::Base.stub!(:subclasses).and_return([@klass1, @klass2, @klass3])
    end
    
    describe ".factories" do
      it "should create one for each machinist make method" do
        Pickle::Adapter::Machinist.should_receive(:new).with(@klass1, 'make').once
        Pickle::Adapter::Machinist.should_receive(:new).with(@klass3, 'make').once
        Pickle::Adapter::Machinist.should_receive(:new).with(@klass3, 'make_special').once
        Pickle::Adapter::Machinist.should_not_receive(:new).with(@klass2, anything)
        
        Pickle::Adapter::Machinist.factories
      end
      
      describe ".new(Class, 'make')" do
        before do
          @factory = Pickle::Adapter::Machinist.new(@klass1, 'make')
        end
        
        it "should have underscored name of Class as #name" do
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
          @factory.name.should == 'special_three'
        end
        
        it "#create(attrs) should call Class.make_special(attrs)" do
          @klass3.should_receive(:make_special).with({:key => "val"})
          @factory.create(:key => "val")
        end
      end
    end
  end
end