begin
  require 'activerecord'
rescue LoadError
  require 'active_record'
end

class ActiveRecord::Base
  module PickleOrmAdapter
    include Pickle::OrmAdapter

    # Do not consider these to be part of the class list
    def self.except_classes
      @@except_classes ||= [
        "CGI::Session::ActiveRecordStore::Session",
        "ActiveRecord::SessionStore::Session"
      ]
    end

    # Gets a list of the available models for this adapter
    def self.model_classes
      begin
        klasses = ::ActiveRecord::Base.__send__(:descendants) # Rails 3
      rescue
        klasses = ::ActiveRecord::Base.__send__(:subclasses) # Rails 2
      end

      klasses.select do |klass|
        !klass.abstract_class? && !except_classes.include?(klass.name)
      end
    end

    # Get an instance by id of the model
    def self.get_model(klass, id)
      klass.find(id)
    end

    # Find the first instance matching conditions
    def self.find_first_model(klass, conditions)
      klass.find(:first, :conditions => conditions)
    end

    # Find all models matching conditions
    def self.find_all_models(klass, conditions)
      klass.find(:all, :conditions => conditions)
    end
    
    # Create a model using attributes
    def self.create_model(klass, attributes)
      klass.create!(attributes)
    end
  end
end
