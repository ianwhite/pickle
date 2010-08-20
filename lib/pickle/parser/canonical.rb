module Pickle
  class Parser
    module Canonical
      
    protected
      # returns really underscored name
      def canonical(str)
        str.nil? ? nil : str.to_s.underscore.gsub(' ','_').gsub('/','_')
      end
    end
  end
end