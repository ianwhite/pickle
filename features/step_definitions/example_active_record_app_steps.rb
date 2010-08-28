Given "I create a database setup for the example active_record app" do
  create_file "lib/db.rb", <<-FILE
    require 'active_record'
    
    database = "\#{File.dirname(__FILE__)}/active_record.sqlite"
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => database)
    
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Schema.define(:version => 0) do
        create_table(:users, :force => true) do |t|
          t.string :name, :default => 'made by orm'
        end
        
        create_table(:notes, :force => true) do |t|
          t.string :body, :default => 'made by orm'
          t.belongs_to :owner, :polymorphic => true
        end
      end
    end
  FILE
end

Given "I create the example active_record app models" do
  create_file "lib/user.rb", <<-FILE
    class User < ActiveRecord::Base
      has_many :notes, :as => :owner
      
      def create_welcome_note
        create_note("Welcome \#{name}!")
      end

      def create_note(body)
        notes.create! :body => body
      end
    end
  FILE
  
  create_file "lib/note.rb", <<-FILE
    class Note < ActiveRecord::Base
      belongs_to :owner, :polymorphic => true
    end
  FILE
  
  create_file "lib/models.rb", <<-FILE
    require 'user'
    require 'note'
  FILE
end