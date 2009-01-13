module Pickle
  module Session
    # add ability to parse model names as fields, using a session
    module Parser
      def self.included(parser_class)
        parser_class.alias_method_chain :parse_field, :model
      end

      attr_accessor :session

      def match_field
        "(?:\\w+: (?:#{match_model}|#{match_value}))"
      end

      def parse_field_with_model(field)
        if session && field =~ /^(\w+): #{capture_model}$/
          {$1 => session.model($2)}
        else
          parse_field_without_model(field)
        end
      end    
    end
  end
end