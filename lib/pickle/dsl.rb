module Pickle
  # included into cucumber scenarios via World(Pickle::Scenario)
  #
  # for more fine-grained access to the pickle session, see Pickle::Session::Api
  module Dsl
    include MakeMatcher
    
    # retrieve the model with the given pickle_ref from the pickle session, and re-find it from the database
    # @raise Pickle::UnknownModelError
    # @return Object the stored model
    def model(pickle_ref)
      pickle.retrieve_and_reload(pickle_ref)
    end
    
    # does the model with given pickle_ref exist in the pickle session?
    # @return falsy if pickle_ref not know, truthy otherwise
    def model?(pickle_ref)
      pickle.known?(pickle_ref)
    end
    
    # make a model using the pickle_ref, and optional fields, and store it in the pickle session under its pickle_ref
    # @return Object the newly made model
    def make(pickle_ref, fields = nil)
      pickle.make_and_store(pickle_ref, fields)
    end
    
    # find a model using the given pickle_ref and optional fields, and store it in the pickle session under its pickle_ref
    # @return Object the found object
    def find(pickle_ref, fields = nil)
      pickle.find_and_store(pickle_ref, fields)
    end
    
    # find all models using the given plural factory name, and optional fields, and store them in the pickle session using the factory name
    # @return Array array of found objects
    def find_all(plural, fields = nil)
      pickle.find_all_and_store(plural, fields)
    end
    
    # the pickle session, @see Pickle::Session::Api
    def pickle
      @pickle ||= Pickle::Session.new
    end
  end
end