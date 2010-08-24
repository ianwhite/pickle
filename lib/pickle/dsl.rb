module Pickle
  # included into cucumber scenarios via World(Pickle::Scenario)
  #
  # the pickle object is where all of the action is at, see Pickle::Session::Api
  module Dsl
    include Pickle::MakeMatcher
    include Pickle::Parser
    
    # the pickle session, @see Pickle::Session::Api
    def pickle
      @pickle ||= Pickle::Session.new
    end
    
    delegate :model, :to => :pickle    
  end
end