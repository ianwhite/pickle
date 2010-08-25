require 'spec_helper'

describe Pickle::Session::Api, "object" do
  subject do
    Object.new.tap do |obj|
      obj.extend Pickle::Session::Api
      obj.stub!(:config).and_return Pickle::Config.new
      obj.stub!(:jar).and_return mock
    end
  end

  let(:model) {mock}
  let(:raw_pickle_ref) {mock}
  let(:raw_pickle_fields) {mock}
  let(:converted_pickle_ref) {mock}
  let(:converted_pickle_fields) {mock}
  
  specify "needs a #config (Pickle::Config)" do
    subject.config.should_not be_nil
  end

  specify "needs a #jar (Pickle::Jar)" do
    subject.jar.should_not be_nil
  end
  
  describe "#store" do
    let(:expect_jar_to_receive_model_with_converted_pickle_ref) do
      subject.jar.should_receive(:store).with(model, converted_pickle_ref)      
      subject.should_receive(:ref).with(raw_pickle_ref).and_return converted_pickle_ref        
    end

    describe "(model)" do
      it "should use the model's class name to create the converted pickle_ref, and store in the jar" do
        expect_jar_to_receive_model_with_converted_pickle_ref
        model.class.should_receive(:name).and_return raw_pickle_ref
        subject.store model
      end
    end

    describe "(model, raw_pickle_ref)" do
      it "should store the model in the jar converting the raw_pickle_ref" do
        expect_jar_to_receive_model_with_converted_pickle_ref
        subject.store model, raw_pickle_ref
      end
    end
  end

  describe "#retrieve" do
    describe "(raw_pickle_ref)" do
      it "should retrieve from the jar using the converted pickle_ref" do
        subject.jar.should_receive(:retrieve).with(converted_pickle_ref)
        subject.should_receive(:ref).with(raw_pickle_ref).and_return converted_pickle_ref
        subject.retrieve raw_pickle_ref
      end

      describe "when jar.retrieve raises Pickle::UnknownModelError" do
        before(:each) do
          subject.jar.stub!(:retrieve).and_raise(Pickle::UnknownModelError)
        end

        it "should raise Pickle::UnknownModelError with useful feedback" do
          subject.should_receive(:ref).with(raw_pickle_ref).and_return converted_pickle_ref
          lambda {subject.retrieve raw_pickle_ref}.should raise_error(Pickle::UnknownModelError, /is not known in this session/)
        end
      end
    end
  end

  shared_examples_for "retrieve_and_reload" do
    it "should call retrieve and reload its return value" do
      subject.should_receive(:retrieve).with(raw_pickle_ref).and_return model
      subject.should_receive(:reload).with(model).and_return model
      do_retrieve_and_reload.should == model
    end
  end  
  
  describe "#model" do
    let(:do_retrieve_and_reload) {subject.model(raw_pickle_ref)}
    it_should_behave_like "retrieve_and_reload"
  end
  
  describe "#retrieve_and_reload" do
    let(:do_retrieve_and_reload) {subject.retrieve_and_reload(raw_pickle_ref)}
    it_should_behave_like "retrieve_and_reload"
  end
  
  describe "#known?(pickle_ref)" do
    it "should convert the pickle_ref and ask the jar whether it includes one" do
      subject.should_receive(:ref).with(raw_pickle_ref).and_return(converted_pickle_ref)
      subject.jar.should_receive(:include?).with(converted_pickle_ref)
      subject.known? raw_pickle_ref
    end
  end
  
  describe "#make_and_store" do
    before(:each) do
      subject.stub!(:ref).and_return converted_pickle_ref
      subject.stub!(:attributes).and_return converted_pickle_fields
      converted_pickle_ref.stub!(:index).and_return pickle_ref_has_index
      subject.stub!(:make).and_return model
      subject.jar.stub!(:store)
    end
    
    describe "(pickle_ref with index)" do
      let(:pickle_ref_has_index) {true}

      it "raises a helpful error" do
        lambda {subject.make_and_store(raw_pickle_ref)}.should raise_error(Pickle::InvalidPickleRefError, /must not contain an index/)
      end
    end

    describe "(raw pickle_ref" do
      let(:pickle_ref_has_index) {false}
      it ") converts the pickle ref" do
        subject.should_receive(:ref).with(raw_pickle_ref)
        subject.make_and_store raw_pickle_ref
      end

      shared_examples_for "stores the made object" do
        it "should store the made object using the converted pickle_ref"  do
          subject.jar.should_receive(:store).with model, converted_pickle_ref
          subject.make_and_store raw_pickle_ref
        end
      end
      
      describe ") (ie. without fields 2nd arg)" do
        it "should call #make with the pickle_ref and no fields" do
          subject.should_receive(:attributes).with(nil).and_return nil
          subject.should_receive(:make).with(converted_pickle_ref, nil).and_return model        
          subject.make_and_store raw_pickle_ref
        end
        
        it_should_behave_like "stores the made object"
      end

      describe ", fields)" do
        it "should call #make with the converted fields" do
          subject.should_receive(:make).with(converted_pickle_ref, converted_pickle_fields).and_return model
          subject.make_and_store raw_pickle_ref, raw_pickle_fields
        end
        
        it_should_behave_like "stores the made object"
      end
    end
  end
  
  describe "#find_and_store" do
    before(:each) do
      subject.stub!(:ref).and_return converted_pickle_ref
      subject.stub!(:attributes).and_return converted_pickle_fields
      converted_pickle_ref.stub!(:index).and_return pickle_ref_has_index
      subject.stub!(:find_first).and_return model
      subject.jar.stub!(:store)
    end
    
    describe "(pickle_ref with index)" do
      let(:pickle_ref_has_index) {true}

      it "raises a helpful error" do
        lambda {subject.find_and_store(raw_pickle_ref)}.should raise_error(Pickle::InvalidPickleRefError, /must not contain an index/)
      end
    end

    describe "(raw pickle_ref" do
      let(:pickle_ref_has_index) {false}
      it "converts the pickle ref" do
        subject.should_receive(:ref).with(raw_pickle_ref)
        subject.find_and_store raw_pickle_ref
      end

      shared_examples_for "stores the found object" do
        it "should store the made object using the converted pickle_ref"  do
          subject.jar.should_receive(:store).with model, converted_pickle_ref
          subject.find_and_store raw_pickle_ref
        end
      end
      
      describe ") (i.e. without fields 2nd arg)" do
        it "should call #find_first with the pickle_ref and no fields" do
          subject.should_receive(:attributes).with(nil).and_return nil
          subject.should_receive(:find_first).with(converted_pickle_ref, nil).and_return model        
          subject.find_and_store raw_pickle_ref
        end
        
        it_should_behave_like "stores the found object"
      end

      describe ", fields)" do
        it "should call #find_first with the converted fields" do
          subject.should_receive(:find_first).with(converted_pickle_ref, converted_pickle_fields).and_return model
          subject.find_and_store raw_pickle_ref, raw_pickle_fields
        end
        
        it_should_behave_like "stores the found object"
      end
    end
  end
  
  describe "#find_all_and_store" do
    let(:another_model) {mock}
    let(:plural_string) {mock}
    before(:each) do
      plural_string.stub!(:singularize).and_return raw_pickle_ref
      subject.stub!(:ref).and_return converted_pickle_ref
      subject.stub!(:attributes).and_return converted_pickle_fields
      subject.stub!(:find_all).and_return [model, another_model]
      subject.jar.stub!(:store)
    end

    describe "(plural string" do
      let(:pickle_ref_has_index) {false}
      it ") converts the plural string to a singular pickle ref" do
        plural_string.should_receive(:singularize).and_return raw_pickle_ref
        subject.should_receive(:ref).with(raw_pickle_ref)
        subject.find_all_and_store plural_string
      end

      shared_examples_for "stores all of the found objects" do
        it "should store all found objects using the converted plural string"  do
          subject.jar.should_receive(:store).with model, converted_pickle_ref
          subject.jar.should_receive(:store).with another_model, converted_pickle_ref        
          subject.find_all_and_store plural_string
        end      
      end
      
      describe ") (i.e. without fields 2nd arg)" do
        it "should call #find_all with the pickle_ref and no fields" do
          subject.should_receive(:attributes).with(nil).and_return nil
          subject.should_receive(:find_all).with(converted_pickle_ref, nil)
          subject.find_all_and_store plural_string
        end
        
        it_should_behave_like "stores all of the found objects"
      end
      
      describe ", fields)" do
        it "should call #find_first with the converted fields" do
          subject.should_receive(:find_all).with(converted_pickle_ref, converted_pickle_fields)
          subject.find_all_and_store plural_string, raw_pickle_fields
        end
        
        it_should_behave_like "stores all of the found objects"
      end
    end
  end
end
