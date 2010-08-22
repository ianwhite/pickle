module Pickle
  class Parser
    # Methods which return Regexps for matching and capturing various pickle expressions. 
    #
    # Optionally, assigning a the Pickle::Config object to #config, to make the matchers
    # aware of the config.
    module Matchers
      attr_accessor :config

      # generate an expression to capture a reference to a model
      # @arguments to restrict the expression to the given factory names
      # @return Regexp
      def pickle_ref(*restrict_to)
        /(#{match_pickle_ref(*restrict_to).source})/
      end
      
      # generate an expression to capture a plural factory name, such as 'users', 'admin users'
      def pickle_plural
        /(#{match_plural_factory.source})/
      end
      
      # generate an expression to capture a fields string suitable for pickle
      def pickle_fields
        /(#{match_fields.source})/
      end
      
      # generate an expression to capture a predicate, suitable for passing to Pickle::MakeMatcher#make_matcher
      def pickle_predicate
        /(#{match_predicate.source})/
      end

    protected
      def match_disjunction(*strings)
        /(?:#{strings.compact.join('|')})/
      end
      
      def match_quoted
        /(?:"[^\"]*")/
      end
      
      def match_factory
        match_disjunction('(?:\w|::\w){2,}', *factories)
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
        config && config.mappings.map(&:search)
      end
      
      def factories
        config && (config.factories | config.aliases.keys)
      end
      
      def plural_factories
        config && factories.map(&:pluralize)
      end
    end
  end
end