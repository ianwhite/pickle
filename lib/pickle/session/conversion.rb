module Pickle
  class Pickle::UnknownFieldsFormatError < RuntimeError; end

  module Session
    # included into Pickle::Session
    module Conversion
      include Pickle::Parser

      # convert a string, hash, or ref into a Pickle::Ref, using config
      def ref(pickle_ref)
        case pickle_ref
        when Pickle::Ref
          pickle_ref
        when Hash
          Pickle::Ref.new(pickle_ref.merge(:config => config))
        else
          Pickle::Ref.new(pickle_ref, :config => config)
        end
      end

      # convert a pickle fields string, or hash, into a hash that is suitable for adapters
      def attributes(fields)   
        if fields.is_a?(Hash)
          convert_hash_attributes(fields)
        else 
          convert_string_attributes(fields.to_s)
        end 
      end

      # convert a string into a value, for example
      #   '1st user'  # => <a user> (if present in pickle jar)
      #   '"foo"'     # => "foo"
      #   "true"      # => true
      #   "-23.78"    # => -23.78  
      def value(str)
        str = str.strip
        retrieve_model_if_pickle_ref(str) or convert_to_value(str)
      end
      
    private
      def retrieve_model_if_pickle_ref(str)
        str =~ /^#{pickle_ref.source}$/ and retrieve(str)
      rescue Pickle::UnknownModelError, Pickle::InvalidPickleRefError
      end
    
      def convert_to_value(str)
        if str =~ /^#{match_value}$/
          eval(str)
        else 
          raise UnknownFieldsFormatError, "#{str.inspect} is in an unknown format"
        end
      end
    
      def convert_hash_attributes(attrs)
        attrs.stringify_keys!
        attrs.each do |key, val|
          (model = retrieve_model_if_pickle_ref(val)) and attrs[key] = model
        end
      end

      def convert_string_attributes(fields)
        attrs = {}
        fields.scan(match_field) do |field|
          key, val = field.split(':', 2)
          attrs[key] = value(val)
        end
        attrs
      end
    end
  end
end