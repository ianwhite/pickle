Given "I create a database setup for the example mongoid app" do
  require 'mongo'
  pending("Install and start mongodb to run the mongoid features") unless (Mongo::Connection.new.db('pickle_test') rescue nil)
  create_file "lib/db.rb", <<-FILE
    require 'mongoid'
    Mongoid.database = Mongo::Connection.new.db('pickle-test')
    Mongoid.database.collections.each(&:remove)
  FILE
end

Given "I create the example mongoid app models" do
  create_file "lib/user.rb", <<-FILE
    class User
      include Mongoid::Document
      field :name, :default => "made by orm"
      references_many :notes, :foreign_key => :owner_id
    
      def create_welcome_note
        create_note("Welcome \#{name}!")
      end
      
      def create_note(body)
        Note.create :owner_id => id, :body => body
      end
    end
  FILE

  create_file "lib/note.rb", <<-FILE
    class Note
      include Mongoid::Document
      field :body, :default => "made by orm"
      referenced_in :owner, :class_name => 'User'
    end
  FILE
  
  create_file "lib/models.rb", <<-FILE
    require 'user'
    require 'note'
  FILE
end