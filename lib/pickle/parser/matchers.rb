module Pickle
  class Parser
    module Matchers
      def match_ordinal
        '(?:\d+(?:st|nd|rd|th))'
      end
  
      def match_index
        "(?:first|last|#{match_ordinal})"
      end
  
      def match_prefix
        '(?:(?:a|an|another|the|that) )'
      end
  
      def match_quoted
        '(?:[^\\"]|\\.)*'
      end
  
      def match_label
        "(?::? \"#{match_quoted}\")"
      end

      def match_value
        "(?:\"#{match_quoted}\"|true|false|\\d+(?:\\.\\d+)?)"
      end

      def match_field
        "(?:\\w+: #{match_value})"
      end
  
      def match_fields
        "(?:#{match_field}, )*#{match_field}"
      end
  
      def match_mapping
        "(?:#{config.mappings.map(&:search).join('|')})"
      end
  
      def match_factory
        "(?:#{config.factories.keys.map{|n| n.gsub('_','[_ ]')}.join('|')})"
      end
      
      def match_plural_factory
        "(?:#{config.factories.keys.map{|n| n.pluralize.gsub('_','[_ ]')}.join('|')})"
      end
      
      def match_indexed_model
        "(?:(?:#{match_index} )?#{match_factory})"
      end
  
      def match_labeled_model
        "(?:#{match_factory}#{match_label})"
      end
  
      def match_model
        "(?:#{match_mapping}|#{match_prefix}?(?:#{match_indexed_model}|#{match_labeled_model}))"
      end
  
      def match_predicate
        "(?:#{config.predicates.map{|m| m.sub(/\?$/,'').gsub('_','[_ ]')}.join('|')})"
      end
      
      # create capture analogues of match methods
      instance_methods.select{|m| m =~ /^match_/}.each do |method|
        eval <<-end_eval                   
          def #{method.sub('match_', 'capture_')}         # def capture_field
            "(" + #{method} + ")"                         #   "(" + match_field + ")"
          end                                             # end
        end_eval
      end
  
      # special capture methods
      def capture_number_in_ordinal
        '(?:(\d+)(?:st|nd|rd|th))'
      end
  
      def capture_name_in_label
        "(?::? \"(#{match_quoted})\")"
      end
  
      def capture_key_and_value_in_field
        "(?:(\\w+): #{capture_value})"
      end
    end
  end
end