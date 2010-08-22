module Pickle
  module Session
    module Conversion
      # convert a string, hash, or ref into a Pickle::Ref, using config
      def ref(pickle_ref)
        case pickle_ref
        when Pickle::Ref then pickle_ref
        when Hash then Pickle::Ref.new(pickle_ref.merge(:config => config))
        else Pickle::Ref.new(pickle_ref, :config => config)
        end
      end
      
      # convert a pickle fields string, or hash, into a hash that is suitable for adapters
      def attributes(fields)   
        fields
      end
    end
  end
end