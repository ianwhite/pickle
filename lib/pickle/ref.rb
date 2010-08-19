module Pickle
  class InvalidPickleRefError < RuntimeError
  end
  
  # parses a pickle ref string into its component parts: factory, index, and label
  #
  # raises an error if the pickle_ref is invalid
  class Ref
    attr_reader :factory, :index, :label
    
    def initialize(string)
      parse_ref(string)
    end
  
  protected
    def parse_ref(orig)
      str = orig.dup
      @index = parse_index!(str)
      @factory = parse_factory!(str)
      @label = parse_label!(str)
      raise InvalidPickleRefError, "'#{orig}' has superfluous: '#{str}'" unless str.blank?
      raise InvalidPickleRefError, "'#{orig}' requires a factory or label" if @factory.blank? && @label.blank?
      raise InvalidPickleRefError, "'#{orig}' can't specify both index and label" if @label.present? && @index.present?
    end
    
    # parse and remove the index from the given string
    # @returns the index or nil
    def parse_index!(string)
      remove_from_and_return_1st_capture!(string, /^#{capture_index}/)
    end

    # parse the factory name from the given string, remove the factory name and optional prefix
    # @returns factory_name or nil
    def parse_factory!(string)
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
      /\b(\w\w+)\b/
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
      /\:? ?\"([\w ]+)\"/
    end
  end
end