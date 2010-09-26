module Pickle
  module Session
    # pickle api is your gateway to making/finding/storing/retrieving models
    #
    #   Terminology:
    #     make      - creating a model in the db, probably using a factory/blueprint
    #     find      - finding a model from the db
    #     store     - store reference to found or made model (in the pickle jar) 
    #     retrieve  - retrieving a model (from the pickle jar) using a pickle reference
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
        pickle_ref, attributes = ref(pickle_ref), attributes(fields)
        apply_label_attribute!(pickle_ref, attributes)
        jar.store make(pickle_ref, attributes), pickle_ref
      end
    
      # finds a model using the ref and fields, and stores it
      def find_and_store(pickle_ref, fields = nil)
        pickle_ref, attributes = ref(pickle_ref), attributes(fields)
        jar.store find_first(pickle_ref, attributes), pickle_ref
      end
    
      # finds all models using a plural factory name and fields, and store them
      def find_all_and_store(plural, fields = nil)
        pickle_ref, attributes = ref(plural.singularize), attributes(fields)
        find_all(pickle_ref, attributes).each do |model|
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
        reload retrieve(pickle_ref)
      end
      alias_method :model, :retrieve_and_reload
        
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
      
      # does a model exist in the db?
      def exist?(pickle_ref, fields = nil)
        find(pickle_ref, attributes(fields))
      rescue
        false
      end
      
    private
      def apply_label_attribute!(pickle_ref, attributes)
        if pickle_ref.label && label_attribute = config.label_map[pickle_ref.factory]
          attributes[label_attribute] ||= pickle_ref.label
        end
      end
    end
  end
end