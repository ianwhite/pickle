require 'spec_helper'

describe Pickle::MakeMatcher do
  it ".make_matcher(example, string) should create a matcher on demand using the string" do
    matcher = Pickle::MakeMatcher.make_matcher(self, "empty")
    matcher.should == be_empty
  end
  
  describe "included into context" do
    include Pickle::MakeMatcher

    describe "context.make_matcher(string)" do
      it "should create a matcher" do
        make_matcher('empty').should == be_empty
      end
    end
    
    describe "parsing input" do
      it "'fairly large' should == be_fairly_large" do
        make_matcher('fairly large').should == be_fairly_large
      end
      
      it "'\"fairly large\"' should == be_fairly_large" do
        make_matcher('"fairly large"').should == be_fairly_large
      end

      it "'\"Fairly Large\"' should == be_fairly_large" do
        make_matcher('"Fairly Large"').should == be_fairly_large
      end
    end
  end
end
