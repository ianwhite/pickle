module Pickle
  def self.parser(options = {})
    @parser ||= Parser.new(options)
  end
  
  class Parser
    attr_reader :config
    
    def initialize(options = {})
      @config = options[:config] || Pickle.config
    end
    
    module Matchers
      def match_ordinal
        '(?:\d+(?:st|nd|rd|th))'
      end
      
      def match_index
        "(?:first|last|#{match_ordinal})"
      end
      
      def match_prefix
        '(?:(?:1|a|an|another|the|that) )'
      end
      
      def match_quoted
        '(?:[^\\"]|\\.)*'
      end
      
      def match_label
        "(?:: \"#{match_quoted}\")"
      end
    
      def match_field
        "(?:\\w+: \"#{match_quoted}\")"
      end
      
      def match_fields
        "(?:#{match_field}, )*#{match_field}"
      end
      
      def match_mapping
        config.mappings.any? ? "(?:#{config.mappings.map(&:search).join('|')})" : ""
      end
      
      def match_factory
        "(?:#{config.factory_names.map{|n| n.gsub('_','[_ ]')}.join('|')})"
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
        "(?:(\\w+): \"(#{match_quoted})\")"
      end
    end
    
    include Matchers
    
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
    
    # given a string like 'foo: "bar"' returns {key => value}
    def parse_field(field)
      if field =~ /^#{capture_key_and_value_in_field}$/
        { $1 => $2 }
      else
        raise ArgumentError, "The field argument is not in the correct format.\n\n'#{field}' did not match: #{match_field}"
      end
    end
    
    # returns really underscored name
    def canonical(str)
      str.to_s.gsub(' ','_').underscore
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
      when '', /last/ then -1
      when /#{capture_number_in_ordinal}/ then $1.to_i - 1
      when /first/ then 0
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