require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle do
  it ".config should be same object on multiple calls" do
    Pickle.config.should == Pickle.config
  end
  
  it ".configure should configure the .config object" do
    Pickle.config.should_receive(:foo).with(:bar)
    Pickle.configure do |c|
      c.foo :bar
    end
  end

  it ".parser should create a parser with the default config" do
    Pickle.instance_variable_set('@parser', nil)
    Pickle::Parser.should_receive(:new).with(:config => Pickle.config)
    Pickle.parser
  end
  
  it ".parser should be same object on multiple calls" do
    Pickle.parser.should == Pickle.parser
  end
end
