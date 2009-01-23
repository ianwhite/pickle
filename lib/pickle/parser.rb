require 'pickle/parser/matchers'

module Pickle
  class Parser
    include Matchers
    
    attr_reader :config
    
    def initialize(options = {})
      @config = options[:config] || raise(ArgumentError, "Parser.new requires a :config")
    end
    
    # given a string like 'foo: "bar", bar: "baz"' returns {"foo" => "bar", "bar" => "baz"}
    def parse_fields(fields)
      if fields.blank?
        {}
      elsif fields =~ /^#{match_fields}$/
        fields.scan(/(#{match_field})(?:,|$)/).inject({}) do |m, match|
          m.merge(parse_field(match[0]))
        end
      else
        raise ArgumentError, "The fields string is not in the correct format.\n\n'#{fields}' did not match: #{match_fields}" 
      end
    end
    
    # given a string like 'foo: expr' returns {key => value}
    def parse_field(field)
      if field =~ /^#{capture_key_and_value_in_field}$/
        { $1 => eval($2) }
      else
        raise ArgumentError, "The field argument is not in the correct format.\n\n'#{field}' did not match: #{match_field}"
      end
    end
    
    # returns really underscored name
    def canonical(str)
      str.to_s.underscore.gsub(' ','_').gsub('/','_')
    end
    
    # return [factory_name, name or integer index]
    def parse_model(model_name)
      apply_mappings!(model_name)
      if /#{capture_index} #{capture_factory}$/ =~ model_name
        [canonical($2), parse_index($1)]
      elsif /#{capture_factory}#{capture_name_in_label}?$/ =~ model_name
        [canonical($1), canonical($2)]
      end
    end
  
    def parse_index(index)
      case index
      when nil, '', 'last' then -1
      when /#{capture_number_in_ordinal}/ then $1.to_i - 1
      when 'first' then 0
      end
    end

  private
    def apply_mappings!(string)
      config.mappings.each do |mapping|
        string.sub! /^#{mapping.search}$/, mapping.replace
      end
    end
  end
end