require 'spec_helper'

describe Pickle::Api do
  include Pickle::Api
  
  describe "#ref" do
    it "<hash> creates a new pickle ref using the hash, and my config" do
      stub!(:config).and_return(mock)
      Pickle::Ref.should_receive(:new).with({:foo => :bar, :config => config}).and_return(pickle_ref = mock)
      ref({:foo => :bar}).should == pickle_ref
    end
    
    it "<string> creates a new pickle ref using the string, and my config" do
      stub!(:config).and_return(mock)
      Pickle::Ref.should_receive(:new).with('foo bar', {:config => config}).and_return(pickle_ref = mock)
      ref('foo bar').should == pickle_ref
    end
    
    it "<pickle_ref> just returns the pickle_ref" do
      pickle_ref = Pickle::Ref.new('factory')
      ref(pickle_ref).should == pickle_ref
    end
  end
end
