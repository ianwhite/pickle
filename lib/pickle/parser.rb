module Pickle
  module Parser
    module Match
      Ordinal = '(?:\d+(?:st|nd|rd|th))'
      Index   = "(?:first|last|#{Ordinal})"
      Prefix  = '(?:1 |a |an |the |that )'
      Quoted  = '(?:[^\\"]|\\.)*'
      Name    = '(?:: "' + Quoted + '")'
      Field   = '(?:\w+: "' + Quoted + '")'
      Fields  = "(?:#{Field}, )*#{Field}"
    
      # model matching - depends on Parse::Config, so load before this if non standard config requried
      ModelMapping  = "(?:#{Pickle::Config.mappings.map(&:first).map{|s| "(?:#{s})"}.join('|')})"
      ModelName     = "(?:#{Pickle::Config.names.map{|n| n.to_s.gsub('_','[_ ]').gsub('/','[:\/ ]')}.join('|')})"
      IndexedModel  = "(?:(?:#{Index} )?#{ModelName})"
      NamedModel    = "(?:#{ModelName}#{Name}?)"
      Model         = "(?:#{ModelMapping}|#{Prefix}?(?:#{IndexedModel}|#{NamedModel}))"
    end
    
    # these are expressions which capture a sub expression
    module Capture
      Ordinal = '(?:(\d+)(?:st|nd|rd|th))'
      Name    = '(?:: "(' + Match::Quoted + ')")'
      Field   = '(?:(\w+): "(' + Match::Quoted + ')")'
    end
    
    # given a string like 'foo: "bar", bar: "baz"' returns {"foo" => "bar", "bar" => "baz"}
    def parse_fields(fields)
      fields.to_s.split(',').inject({}) do |m, field|
        m.merge(parse_field(field.squish))
      end
    end
    
    # given a string like 'foo: "bar"' returns {key => value}
    def parse_field(field)
      field =~ /^#{Capture::Field}$/ or raise ArgumentError, "Field should match /^#{Capture::Field}$/"
      { $1 => $2 }
    end
    
    # returns really underscored name
    def pickle_name(str)
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
        [pickle_name($1), pickle_name($2)]
      elsif /(#{Match::Index}) (#{Match::ModelName})$/ =~ name
        [pickle_name($2), parse_index($1)]
      else
        /(#{Match::ModelName})#{Capture::Name}?$/ =~ name && [pickle_name($1), pickle_name($2)]
      end
    end
    
    def apply_mappings!(string)
      Pickle::Config.mappings.each do |(search, replace)|
        string.sub! /^(?:#{search})$/, replace
      end
    end
  end
end