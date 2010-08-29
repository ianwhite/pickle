require 'spec_helper'

if !defined?(Mongoid) || !(Mongo::Connection.new.db('pickle_spec') rescue nil)
  puts "** set PICKLE_ORM=mongoid and start mongo to run the specs in #{__FILE__}"
else  
  require 'pickle/orm_adapters/mongoid'
  
  Mongoid.configure do |config|
    config.master = Mongo::Connection.new.db('pickle-test')
  end
  
  module MongoidOrmSpec
    class User
      include Mongoid::Document
      field :name
      has_many_related :notes, :foreign_key => :owner_id, :class_name => 'MongoidOrmSpec::Note'
    end

    class Note
      include Mongoid::Document
      field :body, :default => "made by orm"
      belongs_to_related :owner, :class_name => 'MongoidOrmSpec::User'
    end
    
    # here be the specs!
    describe Mongoid::Document::PickleOrmAdapter do
      before do
        User.delete_all
        Note.delete_all
      end
      
      subject { Mongoid::Document::PickleOrmAdapter }
    
      specify "model_classes should return all of datamapper resources" do
        subject.model_classes.to_set.should == [User, Note].to_set
      end
    
      describe "get_model(klass, id)" do
        specify "should return the instance of klass with id if it exists" do
          user = User.create!
          subject.get_model(User, user.id).should == user
        end
      
        specify "should raise an error if the klass does not have an instance with that id" do
          lambda { subject.get_model(User, 1) }.should raise_error
        end
      end
    
      describe "find_first_model(klass, conditions)" do
        specify "should return first model matching conditions, if it exists" do
          user = User.create! :name => "Fred"
          subject.find_first_model(User, :name => "Fred").should == user
        end

        specify "should return nil if no conditions match" do
          subject.find_first_model(User, :name => "Betty").should == nil
        end
      
        specify "should handle belongs_to objects in attributes hash" do
          user = User.create!
          note = Note.create! :owner => user
          subject.find_first_model(Note, :owner => user).should == note
        end
      end
    
      describe "find_all_models(klass, conditions)" do
        specify "should return all models matching conditions" do
          user1 = User.create! :name => "Fred"
          user2 = User.create! :name => "Fred"
          user3 = User.create! :name => "Betty"
          subject.find_all_models(User, :name => "Fred").should == [user1, user2]
        end

        specify "should return empty array if no conditions match" do
          subject.find_all_models(User, :name => "Betty").should == []
        end
      
        specify "should handle belongs_to objects in conditions hash" do
          user1, user2 = User.create!, User.create!
          note1, note2 = Note.create!(:owner_id => user1.id), Note.create!(:owner_id => user2.id)
          subject.find_all_models(Note, :owner => user1).should == [note1]
        end
      end

      describe "create_model(klass, attributes)" do
        it "should create a model using the given attributes" do
          subject.create_model(User, :name => "Fred")
          User.last.name.should == "Fred"
        end
      
        it "should raise error if the create fails" do
          lambda { subject.create_model(User, foo) }.should raise_error
        end
      
        it "should handle belongs_to objects in attributes hash" do
          user = User.create!
          subject.create_model(Note, :owner => user)
          Note.last.owner.should == user
        end
      end
    end
  end
end