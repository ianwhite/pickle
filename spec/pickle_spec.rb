# typed: false
require 'spec_helper'

describe Pickle do
  it ".config should be same object on multiple calls" do
    expect(Pickle.config).to eq(Pickle.config)
  end
  
  it ".configure should configure the .config object" do
    expect(Pickle.config).to receive(:foo).with(:bar)
    Pickle.configure do |c|
      c.foo :bar
    end
  end

  it ".parser should create a parser with the default config" do
    Pickle.instance_variable_set('@parser', nil)
    expect(Pickle::Parser).to receive(:new).with(:config => Pickle.config)
    Pickle.parser
  end
  
  it ".parser should be same object on multiple calls" do
    expect(Pickle.parser).to eq(Pickle.parser)
  end
end
