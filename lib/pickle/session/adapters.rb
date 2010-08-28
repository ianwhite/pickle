module Pickle
  module Session
    # single entry for making and finding models, based on Pickle::Refs
    #
    #   make 'user'                   # make a user model
    #   find_first 'user', 'age: 23'  # find first user model with conditions :age => 23
    #   find_all 'user', :big => true # find all user models with conditions :big => true
    #   reload <user model>           # reloads the given model
    #
    # The way it works is to find a Pickle::Adapter instance 'user', and use that. Adapter
    # instances are usually auto-discovered when Pickle is loaded, but can be set simply by
    # setting the adapter_map, e.g. adapter_map['user'] = <My adapter instance>
    #
    # to include this, you need to implement either
    #   #adapter_map - returns hash of adapters, or
    #   #config - returns a Pickle::Config
    #
    # included into Pickle::Session
    module Adapters
      include Conversion
      
      def make(ref, attributes = {})
        adapter_for(ref).make(attributes)
      end
    
      def find_first(ref, conditions = {})
        adapter_for(ref).find_first(conditions)
      end
    
      def find_all(ref, conditions = {})
        adapter_for(ref).find_all(conditions)      
      end
    
      def reload(model, ref = model.class.name)
        adapter_for(ref).get(model.id)
      end

      def adapter_for(pickle_ref)
        pickle_ref = ref(pickle_ref)
        raise InvalidPickleRefError, "#{pickle_ref.inspect} must have a :factory when finding an adapter" unless pickle_ref.factory
        adapter_map[pickle_ref.factory] or raise NoAdapterError, "can't find an adapter for #{pickle_ref.factory.inspect}"
      end
      
    protected
      def adapter_map
        @adapter_map ||= config.adapter_map
      end
    end
  end
  
  class NoAdapterError < RuntimeError
  end
end