require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Injector do
  describe ".inject Pickle::Session, :into => <a class>" do
    before do
      @class = Class.new
      Pickle::Injector.inject Pickle::Session, :into => @class
      @object = @class.new
    end
    
    it "object should respond_to Pickle:Session methods" do
      @object.should respond_to(:model)
      @object.should respond_to(:create_model)
      @object.should respond_to(:find_model)
    end
    
    it "object.model (a pickle method) should call object.pickle_session.model" do
      @object.pickle_session.should_receive(:model).with('a user')
      @object.model('a user')
    end
  end
end