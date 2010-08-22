require 'spec_helper'

describe Pickle::Session::Adapters do
  include Pickle::Session::Adapters
  before { stub!(:config).and_return(Pickle::Config.new) }
  
  describe "#adapter_for(<ref>)" do
    specify "converts <ref> to a Pickle::Ref" do
      should_receive(:ref).with('ref')
      adapter_for('ref') rescue nil
    end
    
    specify "raises InvalidPickleRefError if the ref doesn't have a factory" do
      lambda { adapter_for(:label => 'foo') }.should raise_error(Pickle::InvalidPickleRefError)
      lambda { adapter_for(:index => 1) }.should raise_error(Pickle::InvalidPickleRefError)
    end
    
    it "should return config.adapter_map[<ref.factory>]" do
      config.adapter_map.should_receive(:[]).with('the_user_factory').and_return(adapter = mock)
      adapter_for('The::User::Factory').should == adapter
    end

    it "should raise NoAdapterError if config.adapter_map[<ref.factory>] is falsy" do
      lambda { adapter_for('not_there') }.should raise_error(Pickle::NoAdapterError)
    end
  end
  
  describe "(with a 'user' adapter available)" do
    let(:user) { mock('user') }
    let(:user_adapter) { mock('user adapter') }
    
    before { config.adapter_map['user'] = user_adapter }
  
    it "#make('user') should return the result of <user adapter>.make({})" do
      user_adapter.should_receive(:make).with({}).and_return(user)
      make('user').should == user
    end
    
    it "#make('user', :foo => :bar) should return the result of <user adapter>.make({:foo => :bar})" do
      user_adapter.should_receive(:make).with({:foo => :bar}).and_return(user)
      make('user', :foo => :bar).should == user
    end
    
    it "#find_first('user') should return the result of <user adapter>.find_first({})" do
      user_adapter.should_receive(:find_first).with({}).and_return(user)
      find_first('user').should == user
    end

    it "#find_first('user', :foo => :bar) should return the result of <user adapter>.find_first({:foo => :bar})" do
      user_adapter.should_receive(:find_first).with({:foo => :bar}).and_return(user)
      find_first('user', :foo => :bar).should == user
    end
    
    it "#find_all('user') should return the result of <user adapter>.find_all({})" do
      user_adapter.should_receive(:find_all).with({}).and_return(user)
      find_all('user').should == user
    end

    it "#find_all('user', :foo => :bar) should return the result of <user adapter>.find_all({:foo => :bar})" do
      user_adapter.should_receive(:find_all).with({:foo => :bar}).and_return(user)
      find_all('user', :foo => :bar).should == user
    end
    
    it "#reload(user, 'user') should return the result of <user adapter>.get(user.id)" do
      user.stub!(:id).and_return(20)
      user_adapter.should_receive(:get).with(20).and_return(user)
      reload(user, 'user').should == user
    end
    
    it "#reload(user) should find an adapter based on the user's class name, and return the result of it.get(user.id)" do
      user.stub!(:class).and_return(mock('user class', :name => 'user_class'))
      should_receive(:adapter_for).with('user_class').and_return(user_adapter)
      user.stub!(:id).and_return(20)
      user_adapter.should_receive(:get).with(20).and_return(user)
      reload(user).should == user
    end
  end
  
  describe "(without a 'user' adapter available)" do
    [:make, :find_first, :find_all].each do |method|
      it "#{method}('user') should raise NoAdapterError" do
        lambda { send(method, 'user') }.should raise_error(Pickle::NoAdapterError)
      end
    end
    
    it "#reload(<anything>, 'user') should raise NoAdapterError" do
      lambda { reload(anything, 'user') }.should raise_error(Pickle::NoAdapterError)
    end
  end
end
