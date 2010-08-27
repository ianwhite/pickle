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

Given "I create an example active_record app user model" do
  create_file "lib/user.rb", <<-FILE
    class User < ActiveRecord::Base
      has_many :notes, :as => :owner
      
      after_create :create_welcome_note
      
      def create_welcome_note
        notes.create! :body => "Welcome \#{name}!"
      end
    end
  FILE
end

Given "I create an example active_record app note model" do
  create_file "lib/note.rb", <<-FILE
    class Note < ActiveRecord::Base
      belongs_to :owner, :polymorphic => true
    end
  FILE
end