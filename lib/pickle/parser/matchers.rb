module Pickle
  module Parser
    # Methods which return Regexps for matching and capturing various pickle expressions. 
    #
    # Optionally, assigning a the Pickle::Config object to #config, to make the matchers
    # aware of the config.
    module Matchers
      attr_accessor :config

    protected
      def match_disjunction(*strings)
        /(?:#{strings.compact.join('|')})/
      end
      
      def match_quoted
        /(?:"[^\"]*")/
      end
      
      def match_word
        /(?:(?:\w|::\w){2,})/
      end
      
      def match_factory
        factories ? match_disjunction(*factories + [match_word.source]) : match_word
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
      
      def match_value
        /(?:nil|true|false|[+-]?[0-9]+(?:\.\d+)?)/
      end
        
      def match_fields
        /#{match_field.source}(?:, #{match_field.source})*/
      end
      
      def match_predicate
        predicates ? match_disjunction(*(predicates + [match_quoted])) : match_quoted
      end
      
      def match_model(*restrict_to)
        factory = restrict_to.any? ? match_disjunction(*restrict_to) : match_factory
        /(?:(?:#{match_index.source} |#{match_prefix.source} )?#{factory.source}(?:(?: |: )#{match_quoted.source})?)/
      end
      
      def match_pickle_ref(*restrict_to)
        if mappings && restrict_to.empty?
          /(?:#{match_disjunction(mappings).source}|#{match_quoted.source}|#{match_model.source})/
        else
          /(?:#{match_quoted.source}|#{match_model(*restrict_to).source})/
        end
      end
      
      def predicates
        config && config.predicates
      end
      
      def mappings
        config && config.mappings.map(&:search).sort_by(&:length).reverse
      end
      
      def factories
        config && (config.factories | config.aliases.keys).sort_by(&:length).reverse
      end
      
      def plural_factories
        config && factories.map(&:pluralize)
      end
    end
  end
end