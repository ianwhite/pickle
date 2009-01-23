module Pickle
  module Email
    # add ability to parse emails
    module Parser
      def match_email
        "(?:#{match_prefix}?(?:#{match_index} )?email)"
      end

      def capture_email
        "(#{match_email})"
      end
      
      def capture_index_in_email
        "(?:#{match_prefix}?(?:#{capture_index} )?email)"
      end
    end
  end
end