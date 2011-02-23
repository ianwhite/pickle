require 'spec_helper'

if !defined?(DataMapper)
  puts "** set PICKLE_ORM=data_mapper to run the specs in #{__FILE__}"
else  
  DataMapper.setup(:default, 'sqlite::memory:')
  
  module DmOrmSpec
    class User
      include DataMapper::Resource
      property :id,   Serial
      property :name, String
      has n, :notes, :child_key => [:owner_id]
    end

    class Note
      include DataMapper::Resource
      property :id,   Serial
      property :body, String
      belongs_to :owner, 'User'
    end
    
    require  'dm-migrations'
    DataMapper.finalize
    DataMapper.auto_migrate!
  
    # here be the specs!
    describe DataMapper::Resource::PickleOrmAdapter do
      before do
        User.destroy
        Note.destroy
      end
      
      subject { DataMapper::Resource::PickleOrmAdapter }
    
      specify "model_classes should return all of datamapper resources" do
        subject.model_classes.should == [User, Note]
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
          note1, note2 = user1.notes.create!, user2.notes.create!
          subject.find_all_models(Note, :owner => user1).should == [note1]
        end
      end

      describe "create_model(klass, attributes)" do
        it "should create a model using the given attributes" do
          subject.create_model(User, :name => "Fred")
          User.last.name.should == "Fred"
        end
      
        it "should raise error if the create fails" do
          lambda { subject.create_model(User, :non_existent => true) }.should raise_error
        end
      
        it "should handle belongs_to objects in attributes hash" do
          user = User.create!
          subject.create_model(Note, :owner => user)
          Note.last.owner.should == user
        end
      
        it "should handle has_many objects in attributes hash" do
          notes = [Note.create!, Note.create!]
          subject.create_model(User, :notes => notes)
          User.last.notes.should == notes
        end
      end
    end
  end
end