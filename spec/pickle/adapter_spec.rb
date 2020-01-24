# typed: true
require 'spec_helper'

require 'active_record'
require 'factory_bot'
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

  describe "adapters: " do
    around do |example|
      begin
        class One < ActiveRecord::Base; end
        class One::Two < ActiveRecord::Base; end
        class Three < ActiveRecord::Base; end
        example.run
      ensure
        Object.send :remove_const, :One
        Object.send :remove_const, :Three
      end
    end

    describe 'ActiveRecord' do
      describe 'with class stubs' do
        before do
          allow(Pickle::Adapter::Orm).to receive(:model_classes).and_return([One, One::Two, Three])
        end

        it ".factories should create one for each active record class" do
          expect(Pickle::Adapter::Orm).to receive(:new).with(One).once
          expect(Pickle::Adapter::Orm).to receive(:new).with(One::Two).once
          expect(Pickle::Adapter::Orm).to receive(:new).with(Three).once
          expect(Pickle::Adapter::Orm.factories.length).to eq(3)
        end

        describe ".new(Class)" do
          before do
            @factory = Pickle::Adapter::Orm.new(One::Two)
          end

          it "should have underscored (s/_) name of Class as #name" do
            expect(@factory.name).to eq('one_two')
          end

          it "#create(attrs) should call Class.create!(attrs)" do
            expect(One::Two).to receive(:create!).with({:key => "val"})
            @factory.create(:key => "val")
          end
        end
      end
    end

    describe 'FactoryBot' do
      before do
        allow(Pickle::Adapter::FactoryBot).to receive(:model_classes).and_return([One, One::Two, Three])

        if defined? ::FactoryBot
          @orig_factories = ::FactoryBot.factories.dup
          ::FactoryBot.factories.clear
          ::FactoryBot::Syntax::Default::DSL.new.factory(:one, :class => One) {}
          ::FactoryBot::Syntax::Default::DSL.new.factory(:two, :class => One::Two) {}
          @factory1 = ::FactoryBot.factories[:one]
          @factory2 = ::FactoryBot.factories[:two]
        else
          @orig_factories, Factory.factories = Factory.factories, {}
          Factory.refine(:one, :class => One) {}
          Factory.refine(:two, :class => One::Two) {}
          @factory1 = Factory.factories[:one]
          @factory2 = Factory.factories[:two]
        end
      end

      after do
        if defined? ::FactoryBot
          ::FactoryBot.factories.clear
          @orig_factories.each {|f| ::FactoryBot.factories.add(f) }
        else
          Factory.factories = @orig_factories
        end
      end

      it ".factories should create one for each factory" do
        expect(Pickle::Adapter::FactoryBot).to receive(:new).with(@factory1, @factory1.name).once
        expect(Pickle::Adapter::FactoryBot).to receive(:new).with(@factory2, @factory2.name).once
        Pickle::Adapter::FactoryBot.factories
      end

      describe ".new(factory, factory_name)" do
        before do
          @factory = Pickle::Adapter::FactoryBot.new(@factory1, @factory1.name)
        end

        it "should have name of factory_name" do
          expect(@factory.name).to eq('one')
        end

        it "should have klass of build_class" do
          expect(@factory.klass).to eq(One)
        end

        unless defined? ::FactoryBot
          it "#create(attrs) should call Factory(<:key>, attrs)" do
            expect(Factory).to receive(:create).with("one", {:key => "val"})
            @factory.create(:key => "val")
          end
        end
      end
    end

    describe 'Fabrication' do
      before do
        @schematic1 = [:one, Fabrication::Schematic::Definition.new(One)]
        @schematic2 = [:two, Fabrication::Schematic::Definition.new(One::Two)]
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
          expect(@factory.klass).to eq(One)
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
        allow(Pickle::Adapter::Machinist).to receive(:model_classes).and_return([One, One::Two, Three])

        One.blueprint {}
        Three.blueprint {}
        Three.blueprint(:special) {}
      end

      it ".factories should create one for each master blueprint, and special case" do
        expect(Pickle::Adapter::Machinist).to receive(:new).with(One, :master).once
        expect(Pickle::Adapter::Machinist).to receive(:new).with(Three, :master).once
        expect(Pickle::Adapter::Machinist).to receive(:new).with(Three, :special).once
        Pickle::Adapter::Machinist.factories
      end

      describe ".new(Class, :master)" do
        before do
          @factory = Pickle::Adapter::Machinist.new(One, :master)
        end

        it "should have underscored (s/_) name of Class as #name" do
          expect(@factory.name).to eq('one')
        end

        it "#create(attrs) should call Class.make!(:master, attrs)" do
          expect(One).to receive(:make!).with(:master, {:key => "val"})
          @factory.create(:key => "val")
        end
      end

      describe ".new(Class, :special)" do
        before do
          @factory = Pickle::Adapter::Machinist.new(Three, :special)
        end

        it "should have 'special_<Class name>' as #name" do
          expect(@factory.name).to eq('special_three')
        end

        it "#create(attrs) should call Class.make!(:special, attrs)" do
          expect(Three).to receive(:make!).with(:special, {:key => "val"})
          @factory.create(:key => "val")
        end
      end
    end
  end
end
