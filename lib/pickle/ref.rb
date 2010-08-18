module Pickle
  class Ref
    attr_reader :factory_name, :index, :label, :attribute
    
    def initialize(string)
      parse_ref(string)
    end
  
  protected
    def parse_ref(string)
      @index = parse_index!(string)
      @factory_name = parse_factory_name!(string)
      @label = parse_label!(string)
    end
    
    # parse and remove the index from the given string
    # @returns the index or nil
    def parse_index!(string)
      remove_from_and_return_1st_capture!(string, /^#{capture_index}/)
    end

    # parse the factory name from the given string, remove the factory name and optional prefix
    # @returns factory_name or nil
    def parse_factory_name!(string)
      remove_from_and_return_1st_capture!(string, /^#{match_prefix}?#{capture_factory_name}/)
    end

    # parse the label, removing it if found
    # @returns the label or nil
    def parse_label!(string)
      remove_from_and_return_1st_capture!(string, /^#{capture_label}/)
    end
    
    def remove_from_and_return_1st_capture!(string, regexp)
      if match_data = string.match(regexp)
        string.sub!(match_data[0], '')
        match_data[1]
      end
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
    
    def capture_label
      /(?:\: )?\"([\w ]+)\"/
    end
  end
end
