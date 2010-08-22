require 'pickle/parser/matchers'
require 'pickle/parser/canonical'

module Pickle
  class InvalidPickleRefError < RuntimeError
  end
  
  class Ref
    include Parser::Matchers
    include Parser::Canonical
    
    attr_reader :factory, :index, :label
    
    # parses a pickle ref string or hash into its component parts: factory, index, and label
    #
    # if a config object is passed, then it will be used to perform any substitutions on :factory, and for parsing
    #
    # @raise ArgumentError
    # @raise Pickle::InvalidPickleRefError
    # @return Pickle::Ref
    def initialize(*args)
      options = args.extract_options!
      self.config = options.delete(:config)
      raise ArgumentError, "specify either a string (with optional :config), or a hash (with optional :config), not both." if args.length > 1 || (options.any? && args.any?)

      args.any? ? parse_string(args.first) : parse_hash(options)
      validate!
    end
    
    def to_s
      "#{factory}#{" index:#{index}" if index}#{" \"#{label}\"" if label}"
    end
    
    def inspect
      "#<Pickle::Ref '#{to_s}'>"
    end
    
  protected
    def validate!
      raise InvalidPickleRefError, "#{inspect} requires a factory or label" if factory.blank? && label.blank?
      raise InvalidPickleRefError, "#{inspect} can't specify both index and label" if label.present? && index.present?
    end
    
    def parse_hash(orig)
      hash = orig.dup
      @factory = hash.delete(:factory)
      @index = hash.delete(:index)
      @label = hash.delete(:label)
      raise InvalidPickleRefError, "superfluous/unknown options: #{hash.inspect}" unless hash.empty?
    end
  
    def parse_string(orig)
      str = orig.dup
      apply_mappings!(str)
      @index = parse_index!(str)
      @factory = parse_factory!(str)
      @label = parse_label!(str)
      raise InvalidPickleRefError, "superfluous: '#{str}'" unless str.blank?
    end
    
    # parse and remove the index from the given string
    # @return the index or nil
    def parse_index!(string)
      if word = remove_from_and_return_1st_capture!(string, /^(?:the )?(#{match_index_word}) /)
        index_word_to_i word
      end
    end

    # parse the factory name from the given string, remove the factory name and optional prefix
    # @return factory_name or nil
    def parse_factory!(string)
      canonical remove_from_and_return_1st_capture!(string, /^(?:#{match_prefix} )?(#{match_factory})/)
    end

    # parse the label, removing it if found
    # @return the label or nil
    def parse_label!(string)
      label = remove_from_and_return_1st_capture!(string, /^(?: |: )?(#{match_quoted})/)
      label && label.gsub('"', '')
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
    
    def apply_mappings!(string)
      config && config.mappings.each do |mapping|
        string.sub! /^#{mapping.search}$/, mapping.replacement
      end
    end
  end
end