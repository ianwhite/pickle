module Pickle
  class Ref
    attr_reader :factory_name, :index, :label, :attribute
    
    def initialize(string)
      parse_ref(string)
    end
  
  protected
    def parse_ref(string)
      @index = parse_index(string)
      @factory_name = (string =~ /^(?:#{match_prefix}|#{capture_index})?#{capture_factory_name}/ && $2)
    end
    
    def parse_index(string)
      string =~ /^#{capture_index}#{capture_factory_name}/ && $1
    end
    
    def capture_factory_name
      /(\w+)/
    end
    
    def match_prefix
      /(?:(?:a|an|another|the|that) )/
    end
    
    def match_ordinal
      /\d+(?:st|nd|rd|th)/
    end
    
    def capture_index
      /(?:the )?(first|last|#{match_ordinal}) ?/
    end
  end
end
