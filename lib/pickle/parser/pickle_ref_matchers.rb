module Pickle
  class Parser
    module PickleRefMatchers
      def pickle_ref
        /\b((?:#{match_index}|#{match_prefix})?#{match_factory}#{match_label}?)\b/
      end
      
      def match_factory
        /(?:\b\w\w+\b)/
      end
      
      def capture_factory
        /(?:\b(\w\w+)\b)/
      end

      def match_prefix
        /(?:(?:a|an|another|the|that) )/
      end

      def match_ordinal
        /\d+(?:st|nd|rd|th)/
      end

      def match_index_word
        /(?:first|last|#{match_ordinal})/
      end

      def match_index
        /(?:(?:the )?#{match_index_word} )/
      end
      
      def capture_index
        /(?:(?:the )?(#{match_index_word}) )/
      end

      def match_label
        /(?:\:? ?\"[\w ]+\")/
      end
      
      def capture_label
        /(?:\:? ?\"([\w ]+)\")/
      end
    end
  end
end