Given "I create a database setup for the example data_mapper app" do
  create_file "lib/db.rb", <<-FILE
    require 'dm-core'
    DataMapper.setup(:default, 'sqlite::memory:')
  FILE
end

Given "I create the example data_mapper app models" do
  create_file "lib/user.rb", <<-FILE
    class User
      include DataMapper::Resource
      
      property :id,   Serial
      property :name, String, :default  => "made by orm"

      has n, :notes, :child_key => [:owner_id]
      
      def create_welcome_note
        notes.create! :body => "Welcome \#{name}!"
      end
    end
  FILE

  create_file "lib/note.rb", <<-FILE
    class Note
      include DataMapper::Resource
      
      property :id,   Serial
      property :body, String, :default => "made by orm"
      
      belongs_to :owner, 'User'
    end
  FILE
  
  create_file "lib/models.rb", <<-FILE
    require 'user'
    require 'note'
    
    require  'dm-migrations'
    DataMapper.finalize
    DataMapper.auto_migrate!
  FILE
end