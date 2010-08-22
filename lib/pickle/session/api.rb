module Pickle
  module Session
    # pickle api is your gateway to making/finding/storing/retrieving models
    #
    #   Terminology:
    #     make      - creating a model in the db, probably using a factory/bluperint
    #     find      - finding a model from the db
    #     store     - remembering an existing model (in the pickle jar) 
    #     retrieve  - retrieving a remembered model (from the pickle jar) using a pickle ref
    #
    # Example use, in a cucumber scenario:
    #
    #   # create and store fred, and store his site for later reference
    #   fred = pickle.make_and_store :factory => 'website_owner', :label => 'fred'
    #   pickle.store fred.site, :label => "fred's site"
    #
    #   # check what models pickle knows of
    #   pickle.known?(:label => 'fred') # => true
    #   pickle.known?('website_owner')  # => true
    #   pickle.known?('site')           # => true
    #   pickle.known?('site "fred"')    # => false
    #
    #   # these are all ways of retrieving the site
    #   pickle.retrieve 'the site'
    #   pickle.retrieve :label => "fred's site"
    #   pickle.retrieve '"fred's site"'
    #   pickle.retrieve 'last site'
    #   pickle.retrieve('fred').site
    #
    # included into Pickle::Session
    module Api
      include Conversion
      
      # makes a model using the ref and fields, and stores it
      def make_and_store(pickle_ref, fields = nil)
        pickle_ref, fields = ref(pickle_ref), attributes(fields)
        raise InvalidPickleRefError, "#{pickle_ref.inspect} must not contain an index for #make_and_store" if pickle_ref.index
        jar.store make(pickle_ref, fields), pickle_ref
      end
    
      # finds a model using the ref and fields, and stores it
      def find_and_store(pickle_ref, fields = nil)
        pickle_ref, fields = ref(pickle_ref), attributes(fields)
        raise InvalidPickleRefError, "#{pickle_ref.inspect} must not contain an index for #make_and_store" if pickle_ref.index
        jar.store find_first(pickle_ref, fields), pickle_ref
      end
    
      # finds all models using a plural factory name and fields, and store them
      def find_all_and_store(plural, fields = nil)
        pickle_ref, fields = ref(plural.singularize), attributes(fields)
        find_all(pickle_ref, fields).each do |model|
          jar.store model, pickle_ref
        end
      end
    
      # store a given model, with the optional ref
      def store(model, pickle_ref = nil)
        pickle_ref ||= model.class.name
        jar.store model, ref(pickle_ref)
      end
    
      # retrieve a model that was stored previously, and re-find it
      def retrieve_and_reload(pickle_ref)
        pickle_ref = ref(pickle_ref)
        reload jar.retrieve(pickle_ref), pickle_ref
      end
        
      # retrieve an orignal model object that was stored previously
      def retrieve(pickle_ref)
        jar.retrieve ref(pickle_ref)
      rescue Pickle::UnknownModelError
        raise Pickle::UnknownModelError.new("#{pickle_ref.inspect} is not known in this session.  Use #make_and_store, #find_and_store, or #store to store a model.")
      end
    
      # is a model known?
      def known?(pickle_ref)
        jar.include? ref(pickle_ref)
      end
    end
  end
end