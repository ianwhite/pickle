module Pickle
  # handles storing and retrieveing models using pickle_refs to do so.  This is not the smae as creating/finding models
  # 
  # For cucumber use, it's better to use the methods with the same names found in in Pickle::Session::Api
  #
  # Examples: (FYI - the pickle.create_and_store methods do all of this automatically)
  #
  #   # store a user
  #   jar.store User.make
  #   
  #   # retrieve with:
  #   jar.retrieve Pickle::Ref.new('the user')
  #   jar.retrieve Pickle::Ref.new('user')
  #   jar.retrieve Pickle::Ref.new('the first user')
  #
  #   # store another user, this time labelled
  #   jar.store User.make, :label => "fred"
  #   
  #   # retrieve with:
  #   jar.retrieve Pickle::Ref.new('the user "fred"')
  #   jar.retrieve Pickle::Ref.new('"fred"')
  #
  #   # store a user made with the admin blueprint
  #   jar.store User.make(:admin), :factory => "admin_user"
  #   
  #   # retrieve with:
  #   jar.retrieve Pickle::Ref.new('the admin_user')
  #   jar.retrieve Pickle::Ref.new('the user')
  #
  #   # retrieve all 1st, 2nd and 3rd - in different ways
  #   jar.retrieve Pickle::Ref.new('the first user')
  #   jar.retrieve Pickle::Ref.new('fred')
  #   jar.retrieve Pickle::Ref.new('admin_user')
  #
  #   # what if it's not in the jar?
  #   jar.retrieve Pickle::Ref.new('the 4th user')
  #   # => Pickle::Jar::UnknownModelError
  #
  #   jar.include? Pickle::Ref.new('4th user')
  #   # => false
  #
  #   jar.include? Pickle::Ref.new('user')
  #   # => true
  class Jar
    include Parser::Canonical
    
    # store the given model in the pickle jar.
    #
    # By default it will be stored under its class name (canonical), can also be given a label
    # If given a factory, it will also be stored under that name (canonical)
    #
    # @examples
    #   store object
    #   store object, Pickle::Ref('"fred"')
    #   store object, Pickle::Ref("admin_user")
    #   store object, Pickle::Ref('admin_user "fred"')
    #
    # @raise InvalidPickleRefError if an index is given in the pickle ref
    # @return Object the stored object
    def store(model, ref = nil)
      raise InvalidPickleRefError, "you can't store a model using an index: #{ref.inspect}" if ref && ref.index
      model_class_factory = canonical(model.class.name)
      label = ref && ref.label
      factory = ref && ref.factory
      store_by_factory_and_label(model, model_class_factory, label)
      store_by_factory_and_label(model, factory, label) unless factory == model_class_factory
      model
    end
    
    # retreive the model matching the pickle_ref
    # @raise Pickle::Jar::UnknownModelError raised if the pickle_ref does not refer to a model in this jar
    # @raise Pickle::Jar::AmbiguousLabel raised if a label by its own refers to more than one model
    def retrieve(ref)
      begin
        if ref.factory && ref.label
          labeled_models(ref.label)[ref.factory]
        elsif ref.label
          retrieve_by_label ref.label
        elsif ref.index
          factory_models(ref.factory)[ref.index]
        else
          factory_models(ref.factory).last
        end
      end or raise UnknownModelError
    end
    
    # Does the given pickle_ref refer to a model in this jar?
    # @return boolean
    def include?(ref)
      retrieve(ref)
    rescue UnknownModelError
      false
    end
    
  private
    def store_by_factory_and_label(model, factory, label)
      factory_models(factory) << model
      labeled_models(label)[factory] = model if label.present?
    end

    def retrieve_by_label(label)
      models = labeled_models(label).values.uniq
      raise AmbiguiousLabelError, "#{label.inspect} refers to #{models.length} models.  Specify factory to narrow it down." if models.length > 1
      models[0]
    end
    
    # Hash of arrays, each key is a factory name, each value is an ordered array of models
    def factory_models(factory)
      @factory_models ||= {}
      @factory_models[factory] ||= []
    end
    
    # Hash of hashes, each key is a label, each value is a hash of factory name => model
    def labeled_models(label)
      @labeled_models ||= {}
      @labeled_models[label] ||= {}
    end
  end
  
  class AmbiguiousLabelError < RuntimeError
  end

  class UnknownModelError < RuntimeError
  end
end