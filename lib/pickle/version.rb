module Pickle
  module Version
    Major = 0
    Minor = 1
    Tiny  = 2
    
    String = [Major, Minor, Tiny].join('.')
  end
end