# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '../../../../../../config/environment')
require 'cucumber/rails/world'
Cucumber::Rails.use_transactional_fixtures

# Comment out the next line if you're not using RSpec's matchers (should / should_not) in your steps.
require 'cucumber/rails/rspec'

###############################################
# Set up a complete app here for testing Pickle

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
  end
end


# Models
class Fork < ActiveRecord::Base
  validates_presence_of :name
  has_many :tines
  
  def completely_rusty?
    tines.map(&:rusty?).uniq == [true]
  end
end

class Tine < ActiveRecord::Base
  validates_presence_of :fork
  belongs_to :fork
end

class Spoon < ActiveRecord::Base
  validates_presence_of :name
end

# Factories
require 'factory_girl'

Factory.sequence :fork_name do |n|
  "fork %d04" % n
end

Factory.define :fork do |f|
  f.name { Factory.next(:fork_name) }
end

Factory.define :tine do |t|
  t.association :fork
end

Factory.define :rusty_tine, :class => Tine do |t|
  t.association :fork
  t.rusty true
end

Factory.define :fancy_fork, :class => Fork do |t|
  t.name { "Fancy " + Factory.next(:fork_name) }
end

# Blueprints
require 'machinist'
Spoon.blueprint do
  name "fred"
end

#### End of app setup

# require pickle, and set up a mapping
Pickle::Config.map 'I|me', :to => 'fancy fork: "of morgoth"'
require 'pickle/steps'