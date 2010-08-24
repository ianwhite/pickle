module Pickle
  module Parser
    include Matchers
    include Canonical
    include DefaultConfig
    
    # generate an regexp to capture a reference to a model
    # @arguments to restrict the expression to the given factory names
    # @return Regexp
    def pickle_ref(*restrict_to)
      /(#{match_pickle_ref(*restrict_to).source})/
    end
    
    # generate an regexp to capture a plural factory name, such as 'users', 'admin users'
    def pickle_plural
      /(#{match_plural_factory.source})/
    end
    
    # generate an regexp to capture a fields string suitable for pickle
    def pickle_fields
      /(#{match_fields.source})/
    end
    
    # generate an regexp to capture a predicate, suitable for passing to Pickle::MakeMatcher#make_matcher
    def pickle_predicate
      /(#{match_predicate.source})/
    end
    
    class Object
      include Pickle::Parser
    end

    def self.new
      Pickle::Parser::Object.new
    end
    
    # given a string like 'foo: "bar", bar: "baz"' returns {"foo" => "bar", "bar" => "baz"}
    #def parse_fields(fields)
    #  if fields.blank?
    #    {}
    #  elsif fields =~ /^#{match_fields}$/
    #    fields.scan(/(#{match_field})(?:,|$)/).inject({}) do |m, match|
    #      m.merge(parse_field(match[0]))
    #    end
    #  else
    #    raise ArgumentError, "The fields string is not in the correct format.\n\n'#{fields}' did not match: #{match_fields}" 
    #  end
    #end
    #
    ## given a string like 'foo: expr' returns {key => value}
    #def parse_field(field)
    #  if field =~ /^#{capture_key_and_value_in_field}$/
    #    { $1 => eval($2) }
    #  else
    #    raise ArgumentError, "The field argument is not in the correct format.\n\n'#{field}' did not match: #{match_field}"
    #  end
    #end
    #
    ## returns really underscored name
    #def canonical(str)
    #  str.to_s.underscore.gsub(' ','_').gsub('/','_')
    #end
    #
    ## return [factory_name, name or integer index]
    #def parse_model(model_name)
    #  apply_mappings!(model_name)
    #  if /#{capture_index} #{capture_factory}$/ =~ model_name
    #    [canonical($2), parse_index($1)]
    #  elsif /#{capture_factory}#{capture_name_in_label}?$/ =~ model_name
    #    [canonical($1), canonical($2)]
    #  end
    #end
  end
end