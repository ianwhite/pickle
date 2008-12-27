require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Adapter do
  it ".factories should raise NotImplementedError" do
    lambda{ Pickle::Adapter.factories }.should raise_error(NotImplementedError)
  end
  
  it "#create should raise NotImplementedError" do
    lambda{ Pickle::Adapter.new.create }.should raise_error(NotImplementedError)
  end
end