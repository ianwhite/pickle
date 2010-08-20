require 'spec_helper'

describe Pickle::MakeMatcher do
  shared_examples_for "be_empty matcher" do
    describe "should match" do
      specify("[]") { [].should subject }
      specify("''") { "".should subject }
    end
    
    describe "should_not match" do
      specify("[1]") { [1].should_not subject }
      specify("'1'") { "1".should_not subject }
    end
  end
  
  describe ".make_matcher(example, 'empty')" do
    subject { Pickle::MakeMatcher.make_matcher(self, "empty") }
    it_should_behave_like "be_empty matcher"
  end
    
  describe "(included)" do
    include Pickle::MakeMatcher

    describe "#make_matcher(string)" do
      subject { make_matcher('empty') }
      it_should_behave_like "be_empty matcher"
    end
    
    describe "asking if something is #fairly_large? should work with" do
      subject { mock }
      before { subject.should_receive(:fairly_large?).and_return(true) }
      
      specify "'fairly large'" do
        should make_matcher('fairly large')
      end
      
      specify "'\"fairly large\"'" do
        should make_matcher('"fairly large"')
      end

      specify "'\"Fairly Large\"'" do
        should make_matcher('"Fairly Large"')
      end
    end
  end
end
