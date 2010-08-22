module Pickle
  module Session
    # single entry for making and finding models, based on Pickle::Refs
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
        config.adapter_map[pickle_ref.factory] or raise NoAdapterError, "can't find an adapter for #{pickle_ref.factory.inspect}"
      end
    end
  end
  
  class NoAdapterError < RuntimeError
  end
end