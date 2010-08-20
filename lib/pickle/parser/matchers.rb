module Pickle
  class Parser
    # Methods which return Regexps for matching and capturing various pickle expressions. 
    #
    # Optionally, assigning a the Pickle::Config object to #config, to make the matchers
    # aware of the config.
    module Matchers
      attr_accessor :config

      delegate :factories, :plural_factories, :predicates, :mapping_searches, :to => :config, :allow_nil => true

      def match_disjunction(*strings)
        /(?:#{strings.compact.join('|')})/
      end
      
      def capture_disjunction(*strings)
        /(#{strings.compact.join('|')})/
      end
      
      def match_quoted
        /(?:"[^\"]*")/
      end
      
      def capture_quoted
        /(?:"([^\"]*)")/
      end
      
      def match_factory
        match_disjunction('\w\w+', *factories)
      end

      def match_plural_factory
        match_disjunction('\w\w+', *plural_factories)
      end

      def match_prefix
        /(?:a|an|another|the|that)/
      end

      def match_ordinal
        /\d+(?:st|nd|rd|th)/
      end

      def match_index_word
        /(?:first|last|#{match_ordinal.source})/
      end

      def match_index
        /(?:(?:the )?#{match_index_word.source})/
      end
      
      def match_field
        /(?:\w+\: [^,]+(?=$|,))/
      end
      
      def match_fields
        /#{match_field.source}(?:, #{match_field.source})*/
      end
      
      def match_predicate
        predicates ? match_disjunction(*(predicates + [match_quoted.source])) : match_quoted
      end
      
      def match_model
        /(?:(?:#{match_index.source} |#{match_prefix.source} )?#{match_factory.source}(?:(?: |: )#{match_quoted.source})?)/
      end
      
      def match_pickle_ref
        /(?:#{mapping_searches ? match_disjunction(mapping_searches).source + '|' : ''}#{match_quoted.source}|#{match_model.source})/
      end
      
      def capture_index
        /(?:(?:the )?(#{match_index_word.source}))/
      end
      
      def capture_factory
        /(?:\b(\w\w+)\b)/
      end
      
      def capture_plural_factory
        capture_name
      end
        
      def capture_fields
        /(?: (\w+\: .*))/
      end
      
      def capture_model
        /(#{match_model.source})/
      end
      
      def capture_predicate
        predicates ? capture_disjunction(*(predicates + [match_quoted.source])) : /(#{match_quoted.source})/
      end
    end
  end
end