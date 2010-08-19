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
    mock("User class", :name => 'User')
  end

  let :user do
    mock("user", :class => user_class, :id => 1)
  end

  let :user_factory do
    Pickle::Adapter::Orm.new(user_class)
  end

  before do
    config.stub(:factories).and_return('user' => user_factory)
  end

  describe "Pickle::Session proxy missing methods to parser", :shared => true do
    it "should forward to pickle_parser it responds_to them" do
      subject.pickle_parser.should_receive(:parse_model)
      subject.parse_model
    end

    it "should raise error if pickle_parser don't know about em" do
      lambda { subject.parse_infinity }.should raise_error
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
      returning Object.new do |object|
        object.extend Pickle::Session
      end
    end

    it_should_behave_like "Pickle::Session proxy missing methods to parser"
  end

  describe "after storing a single user", :shared => true do
    it "created_models('user') should be array containing the original user" do
      created_models('user').should == [user]
    end

    describe "the original user should be retrievable with" do
      it "created_model('the user')" do
        created_model('the user').should == user
      end

      it "created_model('1st user')" do
        created_model('1st user').should == user
      end

      it "created_model('last user')" do
        created_model('last user').should == user
      end
    end

    describe "(found from db)" do
      let :user_from_db do
        returning user.dup do |from_db|
          from_db.stub!(:id).and_return(100)
        end
      end

      before do
        Pickle::Adapter.stub!(:get_model).with(user_class, 100).and_return(user_from_db)
      end

      it "models('user') should be array containing user" do
        models('user').should == [user_from_db]
      end

      describe "user should be retrievable with" do
        it "model('the user')" do
          model('the user').should == user_from_db
        end

        it "model('1st user')" do
          model('1st user').should == user_from_db
        end

        it "model('last user')" do
          model('last user').should == user_from_db
        end

        it "model!('last user')" do
          model('last user').should == user_from_db
        end
      end
    end
  end

  describe "#create_model" do
    before do
      user_factory.stub!(:create).and_return(user)
    end

    describe "('a user')" do
      it "should call user_factory.create({})" do
        user_factory.should_receive(:create).with({})
        create_model('a user')
      end

      describe "after create," do
        before { create_model('a user') }

        it_should_behave_like "after storing a single user"
      end
    end

    describe "('1 user', 'foo: \"bar\", baz: \"bing bong\"')" do
      it "should call user_factory.create({'foo' => 'bar', 'baz' => 'bing bong'})" do
        user_factory.should_receive(:create).with({'foo' => 'bar', 'baz' => 'bing bong'})
        create_model('1 user', 'foo: "bar", baz: "bing bong"')
      end

      describe "after create," do
        before { create_model('1 user', 'foo: "bar", baz: "bing bong"') }

        it_should_behave_like "after storing a single user"
      end
    end

    describe "('an user: \"fred\")" do
      it "should call user_factory.create({})" do
        user_factory.should_receive(:create).with({})
        create_model('an user: "fred"')
      end

      describe "after create," do
        before { create_model('an user: "fred"') }

        it_should_behave_like "after storing a single user"

        it "created_model('the user: \"fred\"') should retrieve the user" do
          created_model('the user: "fred"').should == user
        end

        it "created_model?('the user: \"shirl\"') should be false" do
          created_model?('the user: "shirl"').should == false
        end

        it "model?('the user: \"shirl\"') should be false" do
          model?('the user: "shirl"').should == false
        end
      end
    end

    describe "with hash" do
      it "should call user_factory.create({'foo' => 'bar'})" do
        user_factory.should_receive(:create).with({'foo' => 'bar'})
        create_model('a user', {'foo' => 'bar'}).should == user
      end

      describe "after create," do
        before { create_model('a user', {'foo' => 'bar'}) }

        it_should_behave_like "after storing a single user"
      end
    end
  end

  describe '#find_model' do
    before do
      Pickle::Adapter.stub!(:find_first_model).with(user_class, anything).and_return(user)
    end

    it "should call user_class.find :first, :conditions => {<fields>}" do
      find_model('a user', 'hair: "pink"').should == user
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
        mock(:hashes => [{'name' => 'Fred'}, {'name' => 'Betty'}])
      end

      it "#create_models_from_table(<plural factory>, <table>) should call create_model for each of the table hashes with plain factory name and return the models" do
        should_receive(:create_model).with("user", 'name' => "Fred").once.ordered.and_return(:fred)
        should_receive(:create_model).with("user", 'name' => "Betty").once.ordered.and_return(:betty)
        create_models_from_table("users", table).should == [:fred, :betty]
      end

      it "#find_models_from_table(<plural factory>, <table>) should call find_model for each of the table hashes with plain factory name and return the models" do
        should_receive(:find_model).with("user", 'name' => "Fred").once.ordered.and_return(:fred)
        should_receive(:find_model).with("user", 'name' => "Betty").once.ordered.and_return(:betty)
        find_models_from_table("users", table).should == [:fred, :betty]
      end
    end

    context "when given a table with a matching pickle ref column" do
      let :table do
        mock(:hashes => [{'user' => "fred", 'name' => 'Fred'}, {'user' => "betty", 'name' => 'Betty'}])
      end

      it "#create_models_from_table(<plural factory>, <table>) should call create_model for each of the table hashes with labelled pickle ref" do
        should_receive(:create_model).with("user \"fred\"", 'name' => "Fred").once.ordered.and_return(:fred)
        should_receive(:create_model).with("user \"betty\"", 'name' => "Betty").once.ordered.and_return(:betty)
        create_models_from_table("users", table).should == [:fred, :betty]
      end

      it "#find_models_from_table(<plural factory>, <table>) should call find_model for each of the table hashes with labelled pickle ref" do
        should_receive(:find_model).with("user \"fred\"", 'name' => "Fred").once.ordered.and_return(:fred)
        should_receive(:find_model).with("user \"betty\"", 'name' => "Betty").once.ordered.and_return(:betty)
        find_models_from_table("users", table).should == [:fred, :betty]
      end
    end
  end

  describe "#find_model!" do
    it "should call find_model" do
      should_receive(:find_model).with('name', 'fields').and_return(user)
      find_model!('name', 'fields')
    end

    it "should call raise error if find_model returns nil" do
      should_receive(:find_model).with('name', 'fields').and_return(nil)
      lambda { find_model!('name', 'fields') }.should raise_error(Pickle::ModelNotKnownError)
    end
  end

  describe "#find_models" do
    before do
      Pickle::Adapter.stub!(:find_all_models).with(user_class, anything).and_return([user])
    end

    it "should call User.find :all, :conditions => {'hair' => 'pink'}" do
      find_models('user', 'hair: "pink"').should == [user]
    end

    describe "after find," do
      before { find_models('user', 'hair: "pink"') }

      it_should_behave_like "after storing a single user"
    end
    
    it "should cope with spaces in the factory name (ie. it should make it canonical)" do
      pickle_parser.stub!(:canonical).and_return('user')
      pickle_parser.should_receive(:canonical).with('u ser').and_return('user')
      find_models('u ser', 'hair: "pink"').should == [user]
    end
  end

  describe 'creating \'a super admin: "fred"\', then \'a user: "shirl"\', \'then 1 super_admin\' (super_admin is factory that returns users)' do
    let(:fred) { mock("fred", :class => user_class, :id => 2) }
    let(:shirl) { mock("shirl", :class => user_class, :id => 3) }
    let(:noname) { mock("noname", :class => user_class, :is => 4) }

    let(:super_admin_factory) do
      Pickle::Adapter::FactoryGirl.new(mock(:build_class => user_class, :factory_name => :super_admin))
    end

    before do
      config.stub(:factories).and_return(user_factory.name => user_factory, super_admin_factory.name => super_admin_factory)
      user_factory.stub(:create).and_return(shirl)
      super_admin_factory.stub(:create).and_return(fred, noname)
    end

    def do_create_users
      create_model('a super admin: "fred"')
      create_model('a user: "shirl"')
      create_model('1 super_admin')
    end

    it "should call Factory.create with <'super_admin'>, <'user'>, <'super_admin'>" do
      super_admin_factory.should_receive(:create).with({}).twice
      user_factory.should_receive(:create).with({}).once
      do_create_users
    end

    describe "after create," do
      before do
        do_create_users
      end

      it "created_models('user') should == [fred, shirl, noname]" do
        created_models('user').should == [fred, shirl, noname]
      end

      it "created_models('super_admin') should == [fred, noname]" do
        created_models('super_admin').should == [fred, noname]
      end

      describe "#created_model" do
        it "'that user' should be noname (the last user created - as super_admins are users)" do
          created_model('that user').should == noname
        end

        it "'the super admin' should be noname (the last super admin created)" do
          created_model('that super admin').should == noname
        end

        it "'the 1st super admin' should be fred" do
          created_model('the 1st super admin').should == fred
        end

        it "'the first user' should be fred" do
          created_model('the first user').should == fred
        end

        it "'the 2nd user' should be shirl" do
          created_model('the 2nd user').should == shirl
        end

        it "'the last user' should be noname" do
          created_model('the last user').should == noname
        end

        it "'the user: \"fred\" should be fred" do
          created_model('the user: "fred"').should == fred
        end

        it "'the user: \"shirl\" should be shirl" do
          created_model('the user: "shirl"').should == shirl
        end
      end
    end
  end

  describe "when 'the user: \"me\"' exists and there is a mapping from 'I', 'myself' => 'user: \"me\"" do
    before do
      self.pickle_parser = Pickle::Parser.new(:config => Pickle::Config.new {|c| c.map 'I', 'myself', :to => 'user: "me"'})
      config.stub(:factories).and_return('user' => user_factory)
      Pickle::Adapter.stub!(:get_model).with(user_class, anything).and_return(user)
      user_factory.stub!(:create).and_return(user)
      create_model('the user: "me"')
    end

    it 'model("I") should return the user' do
      model('I').should == user
    end

    it 'model("myself") should return the user' do
      model('myself').should == user
    end

    it "#parser.parse_fields 'author: user \"JIM\"' should raise Error, as model deos not refer" do
      lambda { pickle_parser.parse_fields('author: user "JIM"') }.should raise_error
    end

    it "#parser.parse_fields 'author: the user' should return {\"author\" => <user>}" do
      pickle_parser.parse_fields('author: the user').should == {"author" => user}
    end

    it "#parser.parse_fields 'author: myself' should return {\"author\" => <user>}" do
      pickle_parser.parse_fields('author: myself').should == {"author" => user}
    end

    it "#parser.parse_fields 'author: the user, approver: I, rating: \"5\"' should return {'author' => <user>, 'approver' => <user>, 'rating' => '5'}" do
      pickle_parser.parse_fields('author: the user, approver: I, rating: "5"').should == {'author' => user, 'approver' => user, 'rating' => '5'}
    end

    it "#parser.parse_fields 'author: user: \"me\", approver: \"\"' should return {'author' => <user>, 'approver' => \"\"}" do
      pickle_parser.parse_fields('author: user: "me", approver: ""').should == {'author' => user, 'approver' => ""}
    end
  end

  describe "convert_models_to_attributes(ar_class, :user => <a user>)" do
    before do
      user.stub(:is_a?).with(ActiveRecord::Base).and_return(true)
    end

    describe "(when ar_class has column 'user_id')" do
      let :ar_class do
        mock('ActiveRecord', :column_names => ['user_id'], :const_get => ActiveRecord::Base::PickleAdapter)
      end

      it "should return {'user_id' => <the user.id>}" do
        convert_models_to_attributes(ar_class, :user => user).should == {'user_id' => user.id}
      end
    end

    describe "(when ar_class has columns 'user_id', 'user_type')" do
      let :ar_class do
        mock('ActiveRecord', :column_names => ['user_id', 'user_type'], :const_get => ActiveRecord::Base::PickleAdapter)
      end
            
      it "should return {'user_id' => <the user.id>, 'user_type' => <the user.base_class>}" do
        user.class.should_receive(:base_class).and_return(mock('User base class', :name => 'UserBase'))
        convert_models_to_attributes(ar_class, :user => user).should == {'user_id' => user.id, 'user_type' => 'UserBase'}
      end
    end
  end

  it "#model!('unknown') should raise informative error message" do
    lambda { model!('unknown') }.should raise_error(Pickle::ModelNotKnownError, "The model: 'unknown' is not known in this scenario.  Use #create_model to create, or #find_model to find, and store a reference in this scenario.")
  end

  it "#created_model!('unknown') should raise informative error message" do
    lambda { created_model!('unknown') }.should raise_error(Pickle::ModelNotKnownError)
  end
end
