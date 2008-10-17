module Pickle
  module Parser
    module Match
      Ordinal = '(?:\d+(?:st|nd|rd|th))'
      Index   = "(?:first|last|#{Ordinal})"
      Prefix  = '(?:1 |a |an |another |the |that )'
      Quoted  = '(?:[^\\"]|\\.)*'
      Name    = '(?::? "' + Quoted + '")'
      
      # model matching - depends on Parse::Config, so load before this if non standard config requried
      ModelMapping  = "(?:#{Pickle::Config.mappings.map(&:first).map{|s| "(?:#{s})"}.join('|')})"
      ModelName     = "(?:#{Pickle::Config.names.map{|n| n.to_s.gsub('_','[_ ]').gsub('/','[:\/ ]')}.join('|')})"
      IndexedModel  = "(?:(?:#{Index} )?#{ModelName})"
      NamedModel    = "(?:#{ModelName}#{Name}?)"
      Model         = "(?:#{ModelMapping}|#{Prefix}?(?:#{IndexedModel}|#{NamedModel}))"
      Field         = '(?:\w+: (?:' + Model + '|"' + Quoted + '"))'
      Fields        = "(?:#{Field}, )*#{Field}"
      
    end
    
    # these are expressions which capture a sub expression
    module Capture
      Ordinal = '(?:(\d+)(?:st|nd|rd|th))'
      Name    = '(?::? "(' + Match::Quoted + ')")'
      Field   = '(?:(\w+): "(' + Match::Quoted + ')")'
    end
    
    # given a string like 'foo: "bar", bar: "baz"' returns {"foo" => "bar", "bar" => "baz"}
    def parse_fields(fields)
      if fields.blank?
        {}
      elsif fields =~ /^#{Match::Fields}$/
        fields.scan(/#{Match::Field}/).inject({}) do |m, field|
          m.merge(parse_field(field.squish))
        end
      else
        raise ArgumentError, "The fields string is not in the correct format.\n\n'#{fields}' did not match: #{Match::Fields}" 
      end
    end
    
    # given a string like 'foo: "bar"' returns {key => value}
    def parse_field(field)
      if field =~ /^#{Capture::Field}$/
        { $1 => $2 }
      else
        raise ArgumentError, "The field argument is not in the correct format.\n\n'#{field}' did not match: #{Match::Field}"
      end
    end
    
    # returns really underscored name
    def canonical(str)
      str.to_s.gsub(' ','_').underscore
    end
    
    def parse_index(index)
      case index
      when '', /last/ then -1
      when /#{Capture::Ordinal}/ then $1.to_i - 1
      when /first/ then 0
      end
    end
    
  private
    # return [factory, name or integer index]
    def parse_model(name)
      apply_mappings!(name)
      if /(#{Match::ModelName})#{Capture::Name}$/ =~ name
        [canonical($1), canonical($2)]
      elsif /(#{Match::Index}) (#{Match::ModelName})$/ =~ name
        [canonical($2), parse_index($1)]
      else
        /(#{Match::ModelName})#{Capture::Name}?$/ =~ name && [canonical($1), canonical($2)]
      end
    end
    
    def apply_mappings!(string)
      Pickle::Config.mappings.each do |(search, replace)|
        string.sub! /^(?:#{search})$/, replace
      end
    end
  end
end