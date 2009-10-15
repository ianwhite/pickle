module Pickle
  module Version
    String = File.read(File.dirname(File.dirname(__FILE__)) + '/../VERSION').strip
    Major, Minor, Patch = String.split('.').map{|i| i.to_i}
  end
end