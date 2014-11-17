require 'spec_helper'

# TODO: remove this and push AR stuff into ORM adapter
module ActiveRecord
  class Base
  end
end

module DataMapper
  class Model
  end
end

describe Pickle::Session do
  include Pickle::Session

  let :user_class do
    double("User class", :name => 'User')
  end

  let :user do
    double("user", :class => user_class, :id => 100)
  end

  let :user_factory do
    Pickle::Adapter::Orm.new(user_class)
  end

  before do
    allow(config).to receive(:factories).and_return('user' => user_factory)
  end

  shared_examples_for "Pickle::Session proxy missing methods to parser" do
    it "should forward to pickle_parser it responds_to them" do
      expect(subject.pickle_parser).to receive(:parse_model)
      subject.parse_model
    end

    it "should raise error if pickle_parser don't know about em" do
      expect { subject.parse_infinity }.to raise_error
    end
  end

  describe "including Pickle::Session" do
    subject do
      self
    end

    it_should_behave_like "Pickle::Session proxy missing methods to parser"
  end

  describe "extending Pickle::Session" do
    subject do
      Object.new.tap {|object| object.extend Pickle::Session }
    end

    it_should_behave_like "Pickle::Session proxy missing methods to parser"
  end

  shared_examples_for "after storing a single user" do
    it "created_models('user') should be array containing the original user" do
      expect(created_models('user')).to eq([user])
    end

    describe "the original user should be retrievable with" do
      it "created_model('the user')" do
        expect(created_model('the user')).to eq(user)
      end

      it "created_model('1st user')" do
        expect(created_model('1st user')).to eq(user)
      end

      it "created_model('last user')" do
        expect(created_model('last user')).to eq(user)
      end
    end

    describe "(found from db)" do
      let :user_from_db do
        user.dup.tap {|from_db| allow(from_db).to receive(:id).and_return(100) }
      end

      before do
        allow(Pickle::Adapter).to receive(:get_model).with(user_class, 100).and_return(user_from_db)
      end

      it "models('user') should be array containing user" do
        expect(models('user')).to eq([user_from_db])
      end

      describe "user should be retrievable with" do
        it "model('the user')" do
          expect(model('the user')).to eq(user_from_db)
        end

        it "model('1st user')" do
          expect(model('1st user')).to eq(user_from_db)
        end

        it "model('last user')" do
          expect(model('last user')).to eq(user_from_db)
        end

        it "model!('last user')" do
          expect(model('last user')).to eq(user_from_db)
        end
      end
    end
  end

  describe "#create_model" do
    before do
      allow(user_factory).to receive(:create).and_return(user)
    end

    describe "('a user')" do
      it "should call user_factory.create({})" do
        expect(user_factory).to receive(:create).with({})
        create_model('a user')
      end

      describe "after create," do
        before { create_model('a user') }

        it_should_behave_like "after storing a single user"
      end
    end

    describe "('1 user', 'foo: \"bar\", baz: \"bing bong\"')" do
      it "should call user_factory.create({'foo' => 'bar', 'baz' => 'bing bong'})" do
        expect(user_factory).to receive(:create).with({'foo' => 'bar', 'baz' => 'bing bong'})
        create_model('1 user', 'foo: "bar", baz: "bing bong"')
      end

      describe "after create," do
        before { create_model('1 user', 'foo: "bar", baz: "bing bong"') }

        it_should_behave_like "after storing a single user"
      end
    end

    describe "('an user: \"fred\")" do
      it "should call user_factory.create({})" do
        expect(user_factory).to receive(:create).with({})
        create_model('an user: "fred"')
      end

      describe "after create," do
        before { create_model('an user: "fred"') }

        it_should_behave_like "after storing a single user"

        it "created_model('the user: \"fred\"') should retrieve the user" do
          expect(created_model('the user: "fred"')).to eq(user)
        end

        it "created_model?('the user: \"shirl\"') should be false" do
          expect(created_model?('the user: "shirl"')).to eq(false)
        end

        it "model?('the user: \"shirl\"') should be false" do
          expect(model?('the user: "shirl"')).to eq(false)
        end
      end
    end

    describe "with hash" do
      it "should call user_factory.create({'foo' => 'bar'})" do
        expect(user_factory).to receive(:create).with({'foo' => 'bar'})
        expect(create_model('a user', {'foo' => 'bar'})).to eq(user)
      end

      describe "after create," do
        before { create_model('a user', {'foo' => 'bar'}) }

        it_should_behave_like "after storing a single user"
      end
    end
  end

  describe '#find_model' do
    before do
      allow(Pickle::Adapter).to receive(:find_first_model).with(user_class, anything).and_return(user)
    end

    it "should call user_class.find :first, :conditions => {<fields>}" do
      expect(find_model('a user', 'hair: "pink"')).to eq(user)
    end

    describe "after find," do
      before { find_model('a user', 'hair: "pink"') }

      it_should_behave_like "after storing a single user"
    end

    describe "with hash" do
      it "should call user_class.find('user', {'foo' => 'bar'})" do
        find_model('a user', {'foo' => 'bar'})
      end

      describe "after find," do
        before { find_model('a user', {'foo' => 'bar'}) }

        it_should_behave_like "after storing a single user"
      end
    end
  end

  describe "create and find using plural_factory and table" do
    context "when given a table without a matching pickle ref column" do
      let :table do
        double(:hashes => [{'name' => 'Fred'}, {'name' => 'Betty'}])
      end

      it "#create_models_from_table(<plural factory>, <table>) should call create_model for each of the table hashes with plain factory name and return the models" do
        expect(self).to receive(:create_model).with("user", 'name' => "Fred").once.ordered.and_return(:fred)
        expect(self).to receive(:create_model).with("user", 'name' => "Betty").once.ordered.and_return(:betty)
        expect(create_models_from_table("users", table)).to eq([:fred, :betty])
      end

      it "#find_models_from_table(<plural factory>, <table>) should call find_model for each of the table hashes with plain factory name and return the models" do
        expect(self).to receive(:find_model).with("user", 'name' => "Fred").once.ordered.and_return(:fred)
        expect(self).to receive(:find_model).with("user", 'name' => "Betty").once.ordered.and_return(:betty)
        expect(find_models_from_table("users", table)).to eq([:fred, :betty])
      end
    end

    context "when given a table with a matching pickle ref column" do
      let :table do
        double(:hashes => [{'user' => "fred", 'name' => 'Fred'}, {'user' => "betty", 'name' => 'Betty'}])
      end

      it "#create_models_from_table(<plural factory>, <table>) should call create_model for each of the table hashes with labelled pickle ref" do
        expect(self).to receive(:create_model).with("user \"fred\"", 'name' => "Fred").once.ordered.and_return(:fred)
        expect(self).to receive(:create_model).with("user \"betty\"", 'name' => "Betty").once.ordered.and_return(:betty)
        expect(create_models_from_table("users", table)).to eq([:fred, :betty])
      end

      it "#find_models_from_table(<plural factory>, <table>) should call find_model for each of the table hashes with labelled pickle ref" do
        expect(self).to receive(:find_model).with("user \"fred\"", 'name' => "Fred").once.ordered.and_return(:fred)
        expect(self).to receive(:find_model).with("user \"betty\"", 'name' => "Betty").once.ordered.and_return(:betty)
        expect(find_models_from_table("users", table)).to eq([:fred, :betty])
      end
    end
  end

  describe "#find_model!" do
    it "should call find_model" do
      expect(self).to receive(:find_model).with('name', 'fields').and_return(user)
      find_model!('name', 'fields')
    end

    it "should call raise error if find_model returns nil" do
      expect(self).to receive(:find_model).with('name', 'fields').and_return(nil)
      expect { find_model!('name', 'fields') }.to raise_error(Pickle::Session::ModelNotFoundError)
    end
  end

  describe "#find_models" do
    before do
      allow(Pickle::Adapter).to receive(:find_all_models).with(user_class, anything).and_return([user])
    end

    it "should call User.find :all, :conditions => {'hair' => 'pink'}" do
      expect(find_models('user', 'hair: "pink"')).to eq([user])
    end

    describe "after find," do
      before { find_models('user', 'hair: "pink"') }

      it_should_behave_like "after storing a single user"
    end

    it "should cope with spaces in the factory name (ie. it should make it canonical)" do
      allow(pickle_parser).to receive(:canonical).and_return('user')
      expect(pickle_parser).to receive(:canonical).with('u ser').and_return('user')
      expect(find_models('u ser', 'hair: "pink"')).to eq([user])
    end
  end

  describe 'creating \'a super admin: "fred"\', then \'a user: "shirl"\', \'then 1 super_admin\' (super_admin is factory that returns users)' do
    let(:fred) { double("fred", :class => user_class, :id => 2) }
    let(:shirl) { double("shirl", :class => user_class, :id => 3) }
    let(:noname) { double("noname", :class => user_class, :id => 4) }

    if defined? ::FactoryGirl
      let(:super_admin_factory) { Pickle::Adapter::FactoryGirl.new(double(:build_class => user_class, :name => :super_admin), :super_admin) }
    else
      let(:super_admin_factory) { Pickle::Adapter::FactoryGirl.new(double(:build_class => user_class, :factory_name => :super_admin), :super_admin) }
    end

    before do
      allow(config).to receive(:factories).and_return(user_factory.name => user_factory, super_admin_factory.name => super_admin_factory)
      allow(user_factory).to receive(:create).and_return(shirl)
      allow(super_admin_factory).to receive(:create).and_return(fred, noname)
    end

    def do_create_users
      create_model('a super admin: "fred"')
      create_model('a user: "shirl"')
      create_model('1 super_admin')
    end

    it "should call Factory.create with <'super_admin'>, <'user'>, <'super_admin'>" do
      expect(super_admin_factory).to receive(:create).with({}).twice
      expect(user_factory).to receive(:create).with({}).once
      do_create_users
    end

    describe "after create," do
      before do
        do_create_users
      end

      it "created_models('user') should == [fred, shirl, noname]" do
        expect(created_models('user')).to eq([fred, shirl, noname])
      end

      it "created_models('super_admin') should == [fred, noname]" do
        expect(created_models('super_admin')).to eq([fred, noname])
      end

      describe "#created_model" do
        it "'that user' should be noname (the last user created - as super_admins are users)" do
          expect(created_model('that user')).to eq(noname)
        end

        it "'the super admin' should be noname (the last super admin created)" do
          expect(created_model('that super admin')).to eq(noname)
        end

        it "'the 1st super admin' should be fred" do
          expect(created_model('the 1st super admin')).to eq(fred)
        end

        it "'the first user' should be fred" do
          expect(created_model('the first user')).to eq(fred)
        end

        it "'the 2nd user' should be shirl" do
          expect(created_model('the 2nd user')).to eq(shirl)
        end

        it "'the last user' should be noname" do
          expect(created_model('the last user')).to eq(noname)
        end

        it "'the user: \"fred\" should be fred" do
          expect(created_model('the user: "fred"')).to eq(fred)
        end

        it "'the user: \"shirl\" should be shirl" do
          expect(created_model('the user: "shirl"')).to eq(shirl)
        end
      end
    end
  end

  describe "when 'the user: \"me\"' exists and there is a mapping from 'I', 'myself' => 'user: \"me\"" do
    before do
      self.pickle_parser = Pickle::Parser.new(:config => Pickle::Config.new {|c| c.map 'I', 'myself', :to => 'user: "me"'})
      allow(config).to receive(:factories).and_return('user' => user_factory)
      allow(Pickle::Adapter).to receive(:get_model).with(user_class, anything).and_return(user)
      allow(user_factory).to receive(:create).and_return(user)
      create_model('the user: "me"')
    end

    it 'model("I") should return the user' do
      expect(model('I')).to eq(user)
    end

    it 'model("myself") should return the user' do
      expect(model('myself')).to eq(user)
    end

    it "#parser.parse_fields 'author: user \"JIM\"' should raise Error, as model deos not refer" do
      expect { pickle_parser.parse_fields('author: user "JIM"') }.to raise_error
    end

    it "#parser.parse_fields 'author: the user' should return {\"author\" => <user>}" do
      expect(pickle_parser.parse_fields('author: the user')).to eq({"author" => user})
    end

    it "#parser.parse_fields 'author: myself' should return {\"author\" => <user>}" do
      expect(pickle_parser.parse_fields('author: myself')).to eq({"author" => user})
    end

    it "#parser.parse_fields 'author: the user, approver: I, rating: \"5\"' should return {'author' => <user>, 'approver' => <user>, 'rating' => '5'}" do
      expect(pickle_parser.parse_fields('author: the user, approver: I, rating: "5"')).to eq({'author' => user, 'approver' => user, 'rating' => '5'})
    end

    it "#parser.parse_fields 'author: user: \"me\", approver: \"\"' should return {'author' => <user>, 'approver' => \"\"}" do
      expect(pickle_parser.parse_fields('author: user: "me", approver: ""')).to eq({'author' => user, 'approver' => ""})
    end
  end

  describe "convert_models_to_attributes(ar_class, :user => <a user>)" do
    before do
      allow(user).to receive(:is_a?).with(ActiveRecord::Base).and_return(true)
    end

    describe "(when ar_class has column 'user_id')" do
      let :ar_class do
        double('ActiveRecord', :column_names => ['user_id'], :const_get => ActiveRecord::Base::PickleAdapter)
      end

      it "should return {'user_id' => <the user.id>}" do
        expect(convert_models_to_attributes(ar_class, :user => user)).to eq({'user_id' => user.id})
      end
    end

    describe "(when ar_class has columns 'user_id', 'user_type')" do
      let :ar_class do
        double('ActiveRecord', :column_names => ['user_id', 'user_type'], :const_get => ActiveRecord::Base::PickleAdapter)
      end

      it "should return {'user_id' => <the user.id>, 'user_type' => <the user.base_class>}" do
        expect(user.class).to receive(:base_class).and_return(double('User base class', :name => 'UserBase'))
        expect(convert_models_to_attributes(ar_class, :user => user)).to eq({'user_id' => user.id, 'user_type' => 'UserBase'})
      end
    end
  end

  it "#model!('unknown') should raise informative error message" do
    expect { model!('unknown') }.to raise_error(Pickle::Session::ModelNotKnownError, "The model: 'unknown' is not known in this scenario.  Use #create_model to create, or #find_model to find, and store a reference in this scenario.")
  end

  it "#created_model!('unknown') should raise informative error message" do
    expect { created_model!('unknown') }.to raise_error(Pickle::Session::ModelNotKnownError)
  end
end
