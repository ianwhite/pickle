module Pickle
  module Version
    String = File.read(File.dirname(__FILE__) + '/../../VERSION').strip
    Array = String.split('.').map{|i| i.to_i}
    Major = Array[0]
    Minor = Array[1]
    Patch = Array[2] 
  end
end