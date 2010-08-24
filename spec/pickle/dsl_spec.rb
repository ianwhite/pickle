require 'spec_helper'

describe Pickle::Dsl do
  subject { Pickle::Dsl }
  
  its(:included_modules) { should include(Pickle::MakeMatcher) }
  its(:included_modules) { should include(Pickle::Parser) }
  
  describe "when included" do
    include Pickle::Dsl
  
    it "#pickle should create a Pickle::Session::Object and keep referring to that" do
      Pickle::Session::Object.should_receive(:new).and_return(session = mock('pickle'))
      pickle
      pickle.should == session
    end
  
    it "#model should call pickle.model" do
      pickle.should_receive(:model).with('a user').and_return(user = mock)
      model('a user').should == user
    end
  end
end