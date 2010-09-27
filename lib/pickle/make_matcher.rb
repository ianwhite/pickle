module Pickle
  # Takes a string like '"fairly small"', or 'fairly small' and returns the corresponding rspec matcher.
  #
  # include into the scenario/example to get #make_matcher
  #
  # Useful for converting input with spaces and quotes into a method name
  #
  #   Given(/^something should be (big|small|".*")$/) do |something|
  #     @something.should make_matcher(something)
  #   end
  #
  module MakeMatcher
    def self.make_matcher(example, string, prefix = "be")
      example.send "#{prefix}_#{make_method(string)}"
    end
    
    def self.make_method(string)
      string.gsub('"','').gsub("'",'').gsub(' ','_').downcase
    end
    
    delegate :make_method, :to => Pickle::MakeMatcher
    
    def make_matcher(string, prefix = "be")
      Pickle::MakeMatcher.make_matcher(self, string, prefix)
    end
  end
end