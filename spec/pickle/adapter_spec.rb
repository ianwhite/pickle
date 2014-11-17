require 'spec_helper'

require 'active_record'
require 'factory_girl'
require 'fabrication'
require 'machinist/active_record'
require 'pickle/adapters/active_record'

describe Pickle::Adapter do
  it ".factories should raise NotImplementedError" do
    expect { Pickle::Adapter.factories }.to raise_error(NotImplementedError)
  end

  it "#create should raise NotImplementedError" do
    expect { Pickle::Adapter.new.create }.to raise_error(NotImplementedError)
  end

  describe ".model_classes" do
    before do
      Pickle::Adapter.model_classes = nil
    end
  end

  describe "adapters: " do
    before do
      @klass1 = Class.new(ActiveRecord::Base).tap { |k| allow(k).to receive(:name).and_return('One') }
      @klass2 = Class.new(ActiveRecord::Base).tap { |k| allow(k).to receive(:name).and_return('One::Two') }
      @klass3 = Class.new(ActiveRecord::Base).tap { |k| allow(k).to receive(:name).and_return('Three') }
    end

    describe 'ActiveRecord' do

#DEPRECATION WARNING: subclasses is deprecated and will be removed from Rails 3.0 (use descendants instead). (called from __send__ at /Users/pivotal/workspace/factorylabs/protosite/vendor/cache/ruby/1.8/gems/pickle-0.3.1/lib/pickle/adapters/active_record.rb:21)

      describe ".model_classes" do
        it "calls .descendants" do
          expect(::ActiveRecord::Base).to receive(:descendants).and_return([])
          expect(::ActiveRecord::Base).not_to receive(:subclasses)

          ActiveRecord::Base::PickleAdapter.model_classes
        end
      end

      describe 'with class stubs' do
        before do
          allow(Pickle::Adapter::Orm).to receive(:model_classes).and_return([@klass1, @klass2, @klass3])
        end

        it ".factories should create one for each active record class" do
          expect(Pickle::Adapter::Orm).to receive(:new).with(@klass1).once
          expect(Pickle::Adapter::Orm).to receive(:new).with(@klass2).once
          expect(Pickle::Adapter::Orm).to receive(:new).with(@klass3).once
          expect(Pickle::Adapter::Orm.factories.length).to eq(3)
        end

        describe ".new(Class)" do
          before do
            @factory = Pickle::Adapter::Orm.new(@klass2)
          end

          it "should have underscored (s/_) name of Class as #name" do
            expect(@factory.name).to eq('one_two')
          end

          it "#create(attrs) should call Class.create!(attrs)" do
            expect(@klass2).to receive(:create!).with({:key => "val"})
            @factory.create(:key => "val")
          end
        end
      end
    end

    describe 'FactoryGirl' do
      before do
        allow(Pickle::Adapter::FactoryGirl).to receive(:model_classes).and_return([@klass1, @klass2, @klass3])

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
        expect(Pickle::Adapter::FactoryGirl).to receive(:new).with(@factory1, @factory1.name).once
        expect(Pickle::Adapter::FactoryGirl).to receive(:new).with(@factory2, @factory2.name).once
        Pickle::Adapter::FactoryGirl.factories
      end

      describe ".new(factory, factory_name)" do
        before do
          @factory = Pickle::Adapter::FactoryGirl.new(@factory1, @factory1.name)
        end

        it "should have name of factory_name" do
          expect(@factory.name).to eq('one')
        end

        it "should have klass of build_class" do
          expect(@factory.klass).to eq(@klass1)
        end

        unless defined? ::FactoryGirl
          it "#create(attrs) should call Factory(<:key>, attrs)" do
            expect(Factory).to receive(:create).with("one", {:key => "val"})
            @factory.create(:key => "val")
          end
        end
      end
    end

    describe 'Fabrication' do
      before do
        @schematic1 = [:one, Fabrication::Schematic::Definition.new(@klass1)]
        @schematic2 = [:two, Fabrication::Schematic::Definition.new(@klass2)]
        allow(::Fabrication.manager).to receive(:schematics).and_return(Hash[[@schematic1, @schematic2]])
      end

      it '.factories should create one for each fabricator' do
        expect(Pickle::Adapter::Fabrication).to receive(:new).with(@schematic1)
        expect(Pickle::Adapter::Fabrication).to receive(:new).with(@schematic2)

        Pickle::Adapter::Fabrication.factories
      end

      describe ".new" do
        before do
          @factory = Pickle::Adapter::Fabrication.new(@schematic1)
        end

        it ".new should have name of schematic name" do
          expect(@factory.name).to eq('one')
        end

        it "should have klass of build_class" do
          expect(@factory.klass).to eq(@klass1)
        end
      end

      describe ".create" do
        it "returns the fabricated instance" do
          @factory = Pickle::Adapter::Fabrication.new(@schematic1)
          expect(Fabricate).to receive(:create).
              with(@factory.name.to_sym, {:attribute => 'value'})
          @factory.create({:attribute => 'value'})
        end
      end
    end

    describe 'Machinist' do
      before do
        allow(Pickle::Adapter::Machinist).to receive(:model_classes).and_return([@klass1, @klass2, @klass3])

        @klass1.blueprint {}
        @klass3.blueprint {}
        @klass3.blueprint(:special) {}
      end

      it ".factories should create one for each master blueprint, and special case" do
        expect(Pickle::Adapter::Machinist).to receive(:new).with(@klass1, :master).once
        expect(Pickle::Adapter::Machinist).to receive(:new).with(@klass3, :master).once
        expect(Pickle::Adapter::Machinist).to receive(:new).with(@klass3, :special).once
        Pickle::Adapter::Machinist.factories
      end

      describe ".new(Class, :master)" do
        before do
          @factory = Pickle::Adapter::Machinist.new(@klass1, :master)
        end

        it "should have underscored (s/_) name of Class as #name" do
          expect(@factory.name).to eq('one')
        end

        it "#create(attrs) should call Class.make!(:master, attrs)" do
          expect(@klass1).to receive(:make!).with(:master, {:key => "val"})
          @factory.create(:key => "val")
        end
      end

      describe ".new(Class, :special)" do
        before do
          @factory = Pickle::Adapter::Machinist.new(@klass3, :special)
        end

        it "should have 'special_<Class name>' as #name" do
          expect(@factory.name).to eq('special_three')
        end

        it "#create(attrs) should call Class.make!(:special, attrs)" do
          expect(@klass3).to receive(:make!).with(:special, {:key => "val"})
          @factory.create(:key => "val")
        end
      end
    end
  end
end
