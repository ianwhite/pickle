module Pickle
  class Pickle::UnknownFieldsFormatError < RuntimeError; end

  module Session
    # included into Pickle::Session
    module Conversion
      include Pickle::Parser

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
        if fields.is_a?(Hash)
          convert_hash_attributes(fields)
        else 
          convert_string_attributes(fields.to_s)
        end 
      end

      private
      def convert_hash_attributes(fields)
        fields.stringify_keys!
        fields.each do |key, value|
          if value =~ /^#{pickle_ref.source}$/
            begin
              fields[key] = retrieve(value)
            rescue Pickle::UnknownModelError, Pickle::InvalidPickleRefError
            end
          end
        end
      end

      def convert_string_attributes(fields)
        attrs = {}
        fields.scan(match_field) do |field|
          key, value = field.split(':', 2)
          value.strip!

          model = begin
            value = retrieve(value)
          rescue Pickle::UnknownModelError, Pickle::InvalidPickleRefError
            value = case value
            when /^"(.*)"$/ then $1
            when /^'(.*)'$/ then $1
            when /^(#{match_value})$/ then eval($1)
            else 
              raise UnknownFieldsFormatError, "#{field.inspect} is in an unknown format"
            end              
          end

          attrs[key] = value
        end
        attrs
      end
    end
  end
end