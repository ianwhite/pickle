module Pickle
  class InvalidPickleRefError < RuntimeError
  end
  
  # parses a pickle ref string into its component parts: factory, index, and label
  #
  # raises an error if the pickle_ref is invalid
  class Ref
    include Parser::Matchers
    include Parser::Canonical
    
    attr_reader :factory, :index, :index_word, :label
    
    def initialize(string)
      parse_ref(string)
    end
  
  protected
    def parse_ref(orig)
      str = orig.dup
      @index_word = parse_index!(str)
      @index = index_word_to_i(@index_word) if @index_word
      @factory = parse_factory!(str)
      @label = parse_label!(str)
      raise InvalidPickleRefError, "'#{orig}' has superfluous: '#{str}'" unless str.blank?
      raise InvalidPickleRefError, "'#{orig}' requires a factory or label" if @factory.blank? && @label.blank?
      raise InvalidPickleRefError, "'#{orig}' can't specify both index and label" if @label.present? && @index.present?
    end
    
    # parse and remove the index from the given string
    # @return the index or nil
    def parse_index!(string)
      remove_from_and_return_1st_capture!(string, /^(?:the )?(#{match_index_word}) /)
    end

    # parse the factory name from the given string, remove the factory name and optional prefix
    # @return factory_name or nil
    def parse_factory!(string)
      canonical remove_from_and_return_1st_capture!(string, /^(?:#{match_prefix} )?(#{match_factory})/)
    end

    # parse the label, removing it if found
    # @return the label or nil
    def parse_label!(string)
      remove_from_and_return_1st_capture!(string, /^(?: |: )?(#{match_quoted})/).try(:gsub, '"', '')
    end
    
    def remove_from_and_return_1st_capture!(string, regexp)
      if match_data = string.match(regexp)
        string.sub!(match_data[0], '')
        match_data[1]
      end
    end
    
    def index_word_to_i(word)
      case word
      when 'last' then -1
      when 'first' then 0
      else word.gsub(/\D/,'').to_i - 1
      end
    end
  end
end