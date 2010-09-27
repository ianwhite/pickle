module Pickle
  module Parser
    include Matchers
    include Canonical
    include DefaultConfig
    
    # generate a regexp that captures the specification of a new pickle reference, such as:
    #   
    #   a user
    #   another user
    #   the user
    #   the user "Fred"
    #
    # @arguments to restrict the expression to the given factory names
    # @return Regexp
    def pickle_spec(*restrict_to)
      /(#{match_pickle_spec(*restrict_to).source})/
    end
    
    # generate a regexp to capture an existing pickle reference, such as:
    #
    #   the user
    #   that user
    #   the 1st user
    #   2nd last user
    #   the user: "Fred"
    #   user "Fred"
    #   "Fred"
    #   "Fred"'s site
    #   the user's father
    #   
    # @arguments to restrict the expression to the given factory names
    # @return Regexp
    def pickle_ref(*restrict_to)
      /(#{match_pickle_ref(*restrict_to).source})/
    end
    
    # generate a regexp to capture a plural factory name, such as 'users', 'admin users'
    def pickle_plural
      /(#{match_plural_factory.source})/
    end
    
    # generate a regexp to capture a fields string suitable for pickle
    def pickle_fields
      /(#{match_fields.source})/
    end
    
    # generate a regexp to capture a predicate, or method, suitable for passing to Pickle::MakeMatcher#make_matcher
    def pickle_predicate
      /(#{match_predicate.source})/
    end
    
    # generate a regexp to capture a value, which includes a pickle_ref
    def pickle_value
      /(#{match_value.source}|#{match_pickle_ref.source})/
    end
    
    # generate a regexp to capture a pickle ref label
    def pickle_label
      capture_label
    end
    
    class Object
      include Pickle::Parser
    end

    def self.new
      Pickle::Parser::Object.new
    end
  end
end