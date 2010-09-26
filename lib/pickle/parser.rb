module Pickle
  module Parser
    include Matchers
    include Canonical
    include DefaultConfig
    
    # generate a regexp to capture a reference to a model
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
    
    # generate a regexp to capture a predicate, suitable for passing to Pickle::MakeMatcher#make_matcher
    def pickle_predicate
      /(#{match_predicate.source})/
    end
    
    # generate a regexp to capture a value, which includes a pickle_ref
    def pickle_value
      /(#{match_value.source}|#{match_pickle_ref.source})/
    end
    
    class Object
      include Pickle::Parser
    end

    def self.new
      Pickle::Parser::Object.new
    end
  end
end