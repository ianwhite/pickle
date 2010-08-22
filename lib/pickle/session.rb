module Pickle
  # a Pickle::Session holds everything together, may be included, or created as a standalone object with Pickle::Session.new
  # (actually a Pickle::Session::Object)
  # 
  # @see Pickle::Session::Api for a list of the main api methods
  module Session
    include DefaultConfig
    include Adapters
    include Api

    def jar
      @jar ||= Pickle::Jar.new
    end
    
    
    class Object
      include Pickle::Session
    end

    def self.new
      Pickle::Session::Object.new
    end
  end
end