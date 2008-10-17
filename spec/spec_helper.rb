# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.join(File.dirname(__FILE__), "../../../../config/environment"))
require 'spec/rails'

# APP SETUP

# Models
class User < ActiveRecord::Base
end

class FastCar < ActiveRecord::Base
end

class Event < ActiveRecord::Base
  class Create < Event
  end
  
  class Update < Event
  end
end

# Factories
require 'factory_girl'

Factory.define :user do |u|
end

Factory.define :super_admin, :class => User do |u|
end

Factory.define :fast_car do |c|
end

# Pickle Config

Pickle::Config.model_names = ['user', 'fast_car', 'event/create', 'event/update']
Pickle::Config.map 'I|myself', :to => 'user: "me"'
