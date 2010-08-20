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
    def self.make_matcher(example, string)
      predicate = string.gsub('"','').gsub(' ','_').downcase
      example.send "be_#{predicate}"
    end
    
    def make_matcher(string)
      Pickle::MakeMatcher.make_matcher(self, string)
    end
  end
end