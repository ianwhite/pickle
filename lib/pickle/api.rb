module Pickle
  # pickle dsl is your gateway to making/finding/storing/retrieving models
  #
  #   Terminology:
  #     make      - creating a model in the db, probably using a factory/bluperint
  #     find      - finding a model from the db
  #     store     - making a memory of an existing model (in the pickle jar) 
  #     retrieve  - remembering a model (from the pickle jar)
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
  module Api
    # makes a model using the ref and fields, and stores it
    def make_and_store(ref, pickle = nil)
      model = adapters.make(ref_from(ref), attributes_from(fields))
      jar.store model, ref
    end
    
    # finds a model using the ref and fields, and stores it
    def find_and_store(pickle_ref, fields = nil)
      model = adapters.find_first(ref(pickle_ref), attributes(fields))
      jar.store model, ref
    end
    
    # finds all models using a plural factory name and fields, and store them
    def find_all_and_store(plural, fields = nil)
      pickle_ref = ref(plural.singularize)
      adapters.find_all(pickle_ref, attributes_from(fields)).each do |model|
        jar.store model, pickle_ref
      end
    end
    
    # store a given model, with the optional ref
    def store(model, pickle_ref = nil)
      jar.store model, ref(pickle_ref)
    end
    
    # retrieve a model that was stored previously, and re-find it
    def retrieve(pickle_ref)
      adapters.find jar.retrieve(ref(pickle_ref))
    end
        
    # retrieve an orignal model object that was stored previously
    def retrieve_original(pickle_ref)
      jar.retrieve ref(pickle_ref)
    end
    
    # is a model known?
    def known?(pickle_ref)
      jar.include? ref(pickle_ref)
    end
    
    # convert a string, hash, or ref into a Pickle::Ref, aware of config
    def ref(pickle_ref)
      case pickle_ref
      when Pickle::Ref then pickle_ref
      when Hash then Pickle::Ref.new(pickle_ref.merge(:config => config))
      else Pickle::Ref.new(pickle_ref, :config => config)
      end
    end
    
    # convert a string or hash into attributes, aware of models in the jar
    def attributes(pickle_fields)
      
    end
  end
end