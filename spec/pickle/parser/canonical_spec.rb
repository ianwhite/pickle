require 'spec_helper'

describe Pickle::Parser::Canonical do
  include Pickle::Parser::Canonical
  
  specify "#canonical('foo bar') => 'foo_bar'" do 
    canonical("foo bar").should == 'foo_bar'
  end
  
  specify "#canonical('Foo/Bar baz') => 'foo_bar_baz'" do 
    canonical('Foo/Bar baz').should == 'foo_bar_baz'
  end
  
  specify "#canonical nil => nil" do
    canonical(nil).should be_nil
  end
end
