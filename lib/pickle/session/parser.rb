# typed: true
module Pickle
  module Session
    # add ability to parse model names as fields, using a session
    module Parser
      module ParseFieldWithModel
        def parse_field(field)
          if session && field =~ /^(\w+): #{capture_model}$/
            {$1 => session.model!($2)}
          else
            super(field)
          end
        end
      end

      def self.included(parser_class)
        parser_class.send(:prepend,  ParseFieldWithModel)
      end

      attr_accessor :session

      def match_field
        "(?:\\w+: (?:#{match_model}|#{match_value}))"
      end

      def parse_hash(hash)
        hash.inject({}) do |parsed, (key, val)|
          if session && val =~ /^#{capture_model}$/
            parsed.merge(key => session.model($1))
          else
            parsed.merge(key => val)
          end
        end
      end
    end
  end
end
