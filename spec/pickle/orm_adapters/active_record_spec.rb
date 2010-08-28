require 'spec_helper'

if !defined?(ActiveRecord::Base)
  puts "** set PICKLE_SPEC_DB=active_record to run the specs in #{__FILE__}"
else  
  require 'pickle/orm_adapters/active_record'
  
  # setup an activerecord db, and classes, specs are below
  
  database = File.join(File.dirname(__FILE__), '../../../tmp/active_record.sqlite')
  `mkdir -p #{File.dirname(database)}`
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => database)

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define(:version => 0) do
      create_table(:users, :force => true) {|t| t.string :name; t.belongs_to :site }
      create_table(:sites, :force => true) {|t| t.string :name }
      create_table(:notes, :force => true) {|t| t.belongs_to :owner, :polymorphic => true }
    end
  end
  
  # stick the ActiveRecord classes and specs in a namespace to isolate them
  module ArOrmSpec
    class User < ActiveRecord::Base
      belongs_to :site, :class_name => "ArOrmSpec::Site"
      has_many :ar_notes, :as => :owner
    end

    class Site < ActiveRecord::Base
      has_many :users, :class_name => 'ArOrmSpec::User'
      has_many :notes, :as => :owner, :class_name => 'ArOrmSpec::Note'
    end

    class AbstractNoteClass < ActiveRecord::Base
      self.abstract_class = true
    end

    class Note < AbstractNoteClass
      belongs_to :owner, :polymorphic => true
    end
  
    # here be the specs!
    describe ActiveRecord::Base::PickleOrmAdapter do
      before do
        User.delete_all
        Note.delete_all
        Site.delete_all
      end
    
      subject { ActiveRecord::Base::PickleOrmAdapter }
    
      specify "except_classes should return the names of active record session store classes" do
        subject.except_classes.should == ["CGI::Session::ActiveRecordStore::Session", "ActiveRecord::SessionStore::Session"]
      end

      specify "model_classes should return all of the non abstract model classes (that are not in except_classes)" do
        subject.model_classes.should == [User, Site, Note]
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
          site = Site.create!
          user = User.create! :name => "Fred", :site => site
          subject.find_first_model(User, :site => site).should == user
        end

        specify "should handle belongs_to :polymorphic objects in attributes hash" do
          site = Site.create!
          note = Note.create! :owner => site
          subject.find_first_model(Note, :owner => site).should == note
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
          site1, site2 = Site.create!, Site.create!
          user1, user2 = User.create!(:site => site1), User.create!(:site => site2)
          subject.find_all_models(User, :site => site1).should == [user1]
        end
      
        specify "should handle polymorphic belongs_to objects in conditions hash" do
          site1, site2 = Site.create!, Site.create!
          note1, note2 = site1.notes.create!, site2.notes.create!
          subject.find_all_models(Note, :owner => site1).should == [note1]
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
          site = Site.create!
          subject.create_model(User, :site => site)
          User.last.site.should == site
        end
      
        it "should handle polymorphic belongs_to objects in attributes hash" do
          site = Site.create!
          subject.create_model(Note, :owner => site)
          Note.last.owner.should == site
        end
      
        it "should handle has_many objects in attributes hash" do
          users = [User.create!, User.create!]
          subject.create_model(Site, :users => users)
          Site.last.users.should == users
        end
      end
    end
  end
end