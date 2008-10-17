require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Config do
  it "model_names should be factory and active record names" do
    Pickle::Config.model_names.sort.should == ['event/create', 'event/update', 'fast_car', 'super_admin', 'user']
  end
end