# Routes
Rails.application.routes.draw do
  resources :spoons, :controller => 'default'
  resources :forks, :controller => 'default' do
    resources :tines, :controller => 'default' do
      resources :comments, :controller => 'default'
    end
  end
  resources :users, :controller => 'default'
end

# Migrations
ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :forks, :force => true do |t|
      t.string :name
    end
    
    create_table :spoons, :force => true do |t|
      t.string :name
      t.boolean :round, :default => true, :null => false
    end
    
    create_table :tines, :force => true do |t|
      t.belongs_to :fork
      t.boolean :rusty, :default => false, :null => false
    end
    
    create_table :users, :force => true do |t|
      t.string :name, :status, :email
      t.decimal :attitude_score, :precision => 4, :scale => 2
      t.boolean :has_stale_password, :default => false
    end

    create_table :knives, :force => true do |t|
      t.string :name
      t.boolean :sharp, :null => false
    end
  end
end


# Factories for these Fork & Spoon
class Fork < ActiveRecord::Base
  validates_presence_of :name
  has_many :tines
  
  def completely_rusty?
    tines.map(&:rusty?).uniq == [true]
  end
  
  def fancy?
    name =~ /fancy/i
  end
end

class Tine < ActiveRecord::Base
  validates_presence_of :fork
  belongs_to :fork
end

# Machinist blueprint for this
class Spoon < ActiveRecord::Base
  validates_presence_of :name
end

# Fabricator class
class Knife < ActiveRecord::Base
  validates_presence_of :name
end

# we don't want abstract classes getting in there
class AbstractUser < ActiveRecord::Base
  self.abstract_class = true
end

# No factory or blueprint for this
class User < AbstractUser
  validates_presence_of :name
  
  def positive_person?
    !no_attitude? && attitude_score > 0
  end
  
  def no_attitude?
    attitude_score.nil?
  end
end

# controllers
class DefaultController < ActionController::Base
  def index
    render :text => "index: I was invoked with #{request.path}"
  end
  
  def show
    render :text => "show: I was invoked with #{request.path}"
  end
  
  def new
    render :text => "new: I was invoked with #{request.path}"
  end
  
  def edit
    render :text => "edit: I was invoked with #{request.path}"
  end
end

# notifiers
class Notifier < ActionMailer::Base
  include Rails.application.routes.url_helpers
  
  # BC 2.1
  self.view_paths = "#{File.dirname(__FILE__)}/views"
  
  def user_email(user)
    @recipients  = user.email
    @subject     = 'A user email'
    @user = user
    @path = user_path(user)
  end
  
  def email(to, subject, body)
    @recipients  = to
    @subject     = subject
    @body = body
  end
end
