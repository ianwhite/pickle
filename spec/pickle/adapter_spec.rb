require 'spec_helper'

require 'active_record'
require 'factory_girl'
require 'fabrication'
require 'machinist/active_record'
require 'pickle/adapters/active_record'

describe Pickle::Adapter do
  it ".factories should raise NotImplementedError" do
    lambda { Pickle::Adapter.factories }.should raise_error(NotImplementedError)
  end

  it "#create should raise NotImplementedError" do
    lambda { Pickle::Adapter.new.create }.should raise_error(NotImplementedError)
  end

  describe ".model_classes" do
    before do
      Pickle::Adapter.model_classes = nil
    end
  end

  describe "adapters: " do
    before do
      @klass1 = Class.new(ActiveRecord::Base).tap { |k| k.stub!(:name).and_return('One') }
      @klass2 = Class.new(ActiveRecord::Base).tap { |k| k.stub!(:name).and_return('One::Two') }
      @klass3 = Class.new(ActiveRecord::Base).tap { |k| k.stub!(:name).and_return('Three') }
    end

    describe 'ActiveRecord' do

#DEPRECATION WARNING: subclasses is deprecated and will be removed from Rails 3.0 (use descendants instead). (called from __send__ at /Users/pivotal/workspace/factorylabs/protosite/vendor/cache/ruby/1.8/gems/pickle-0.3.1/lib/pickle/adapters/active_record.rb:21)

      describe ".model_classes" do
        it "calls .descendants" do
          ::ActiveRecord::Base.should_receive(:descendants).and_return([])
          ::ActiveRecord::Base.should_not_receive(:subclasses).and_return([])

          ActiveRecord::Base::PickleAdapter.model_classes
        end
      end

      describe 'with class stubs' do
        before do
          Pickle::Adapter::Orm.stub!(:model_classes).and_return([@klass1, @klass2, @klass3])
        end

        it ".factories should create one for each active record class" do
          Pickle::Adapter::Orm.should_receive(:new).with(@klass1).once
          Pickle::Adapter::Orm.should_receive(:new).with(@klass2).once
          Pickle::Adapter::Orm.should_receive(:new).with(@klass3).once
          Pickle::Adapter::Orm.factories.length.should == 3
        end

        describe ".new(Class)" do
          before do
            @factory = Pickle::Adapter::Orm.new(@klass2)
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

    describe 'FactoryGirl' do
      before do
        Pickle::Adapter::FactoryGirl.stub!(:model_classes).and_return([@klass1, @klass2, @klass3])

        if defined? ::FactoryGirl
          @orig_factories = ::FactoryGirl.factories.dup
          ::FactoryGirl.factories.clear
          ::FactoryGirl::Syntax::Default::DSL.new.factory(:one, :class => @klass1) {}
          ::FactoryGirl::Syntax::Default::DSL.new.factory(:two, :class => @klass2) {}
          @factory1 = ::FactoryGirl.factories[:one]
          @factory2 = ::FactoryGirl.factories[:two]
        else
          @orig_factories, Factory.factories = Factory.factories, {}
          Factory.define(:one, :class => @klass1) {}
          Factory.define(:two, :class => @klass2) {}
          @factory1 = Factory.factories[:one]
          @factory2 = Factory.factories[:two]
        end
      end

      after do
        if defined? ::FactoryGirl
          ::FactoryGirl.factories.clear
          @orig_factories.each {|f| ::FactoryGirl.factories.add(f) }
        else
          Factory.factories = @orig_factories
        end
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

        unless defined? ::FactoryGirl
          it "#create(attrs) should call Factory(<:key>, attrs)" do
            Factory.should_receive(:create).with("one", {:key => "val"})
            @factory.create(:key => "val")
          end
        end
      end
    end

    describe 'Fabrication' do
      before do
        @schematic1 = [:one, Fabrication::Schematic.new(@klass1)]
        @schematic2 = [:two, Fabrication::Schematic.new(@klass2)]
        ::Fabrication::Fabricator.stub(:schematics).and_return([@schematic1, @schematic2])
      end

      it '.factories should create one for each fabricator' do
        Pickle::Adapter::Fabrication.should_receive(:new).with(@schematic1)
        Pickle::Adapter::Fabrication.should_receive(:new).with(@schematic2)

        Pickle::Adapter::Fabrication.factories
      end

      describe ".new" do
        before do
          @factory = Pickle::Adapter::Fabrication.new(@schematic1)
        end

        it ".new should have name of schematic name" do
          @factory.name.should == 'one'
        end

        it "should have klass of build_class" do
          @factory.klass.should == @klass1
        end
      end

      describe ".create" do
        it "returns the fabricated instance" do
          @factory = Pickle::Adapter::Fabrication.new(@schematic1)
          ::Fabrication::Fabricator.should_receive(:generate).
              with(@factory.name.to_sym, {:save => true}, {:attribute => 'value'})
          @factory.create({:attribute => 'value'})
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
