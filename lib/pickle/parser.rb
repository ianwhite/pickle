require 'factory_girl'

module Pickle
  module Parser
    MatchOrdinal    = '(?:\d+(?:st|nd|rd|th))'
    CaptureOrdinal  = '(?:(\d+)(?:st|nd|rd|th))'
    MatchIndex      = "(?:first|last|#{MatchOrdinal})"
    MatchPrefix     = '(?:1 |a |an |the |that )'
    MatchName       = '(?:: ".*?")'
    CaptureName     = '(?:: "(.*?)")'
    MatchField      = '(?:\w+: "(?:[^\\"]|\\.)*")'
    MatchFields     = "(?:#{MatchField}, )*#{MatchField}"
    
    module Matchers
      def match_model_name
        "(?:#{Parser.model_match_names.join('|')})"
      end
      
      def match_model
        matcher = '(?:'
          matcher += '(?:' + Parser.mappings.map {|m| "(?:#{m.first})"}.join('|') + ')|' if Parser.mappings.any?
          matcher += "#{MatchPrefix}?"
          matcher += "(?:"
            matcher += "(?:#{MatchIndex} )?#{match_model_name}"
            matcher += "|"
            matcher += "#{match_model_name}#{MatchName}?"
          matcher += ")"
        matcher += ")"
      end
    end

    include Matchers
    extend Matchers
    
    mattr_accessor :mappings
    self.mappings = []
    
    class << self
      attr_accessor_with_default :active_record_names do
        Dir["#{RAILS_ROOT}/app/models/**/**"].reject{|f| f =~ /observer.rb$/}.map{|f| f.sub("#{RAILS_ROOT}/app/models/",'').sub(".rb",'')}
      end
      
      attr_accessor_with_default :factory_names do
        Factory.factories.keys.map(&:to_s)
      end
      
      attr_accessor_with_default :model_names do
        (active_record_names | factory_names)
      end
      
      attr_accessor_with_default :model_match_names do
        model_names.sort.map{|n| n.gsub('_','[_ ]').gsub('/','[\/: ]')}
      end
    
      def map(search, options)
        raise ArgumentError, "Usage: map 'search', :to => 'replace'" unless search.is_a?(String) && options[:to].is_a?(String)
        self.mappings << [search, options[:to]]
      end
      
      def apply_mappings!(string)
        self.mappings.each do |(search, replace)|
          string.sub! /^(?:#{search})$/, replace
        end
      end
    end
    
    # given a string like 'foo: "bar", bar: "baz"' returns {"foo" => "bar", "bar" => "baz"}
    def parse_fields(fields)
      fields.to_s.split(',').inject({}) do |m, field|
        m.merge(parse_field(field))
      end
    end
    
    # given a string like 'foo: "bar"' returns {key => value}
    def parse_field(field)
      key, val = *field.squish.split(': ')
      { key => val.sub(/^"/,'').sub(/"$/,'') }
    end
    
    # returns really underscored name
    def pickle_name(str)
      str.to_s.gsub(' ','_').underscore
    end
    
    def parse_index(index)
      case index
      when '', /last/ then -1
      when /#{CaptureOrdinal}/ then $1.to_i - 1
      when /first/ then 0
      end
    end
    
  private
    # return [factory, name or integer index]
    def parse_model(name)
      Parser.apply_mappings!(name)
      if /(#{match_model_name})#{CaptureName}$/ =~ name
        [pickle_name($1), pickle_name($2)]
      elsif /(#{MatchIndex}) (#{match_model_name})$/ =~ name
        [pickle_name($2), parse_index($1)]
      else
        /(#{match_model_name})#{CaptureName}?$/ =~ name && [pickle_name($1), pickle_name($2)]
      end
    end
  end
end