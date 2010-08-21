require 'spec_helper'

describe Pickle::Jar do
  let(:model_class) { Class.new.tap {|c| c.stub!(:name).and_return('Module::ModelClass') } }
  let(:model) { model_class.new }
  
  shared_examples_for "after storing a model" do
    specify "can be retrieved with Pickle::Ref.new(<model class name>)" do
      subject.retrieve(Pickle::Ref.new('Module::ModelClass')).should == model
    end
    
    specify "can be retrieved with Pickle::Ref.new('underscored_class_name')" do
      subject.retrieve(Pickle::Ref.new('module_model_class')).should == model
    end
    
    specify "can be retrieved with Pickle::Ref.new('last underscored_class_name')" do
      subject.retrieve(Pickle::Ref.new("last module_model_class")).should == model
    end
  end
  
  describe "after storing a model," do
    before { subject.store(model) }
    
    describe "the model" do
      it_should_behave_like "after storing a model"
    end
  end
  
  shared_examples_for "after storing a model with an optional factory" do
    specify "can be retrieved with Pickle::Ref.new('<factory>')" do
      subject.retrieve(Pickle::Ref.new("#{factory}")).should == model
    end
        
    specify "can be retrieve with Pickle::Ref.new('last <factory>')" do
      subject.retrieve(Pickle::Ref.new("last #{factory}")).should == model
    end
  end
  
  describe "after storing a model with an optional factory," do
    let(:factory) { 'factory' }
    before { subject.store(model, Pickle::Ref.new(factory)) }
    
    describe "the model" do
      it_should_behave_like "after storing a model"
      it_should_behave_like "after storing a model with an optional factory"
    end
  end
  
  shared_examples_for "after storing a model with an optional label" do
    specify "can be retrieved with Pickle::Ref.new('<model class name> \"<label>\"')" do
      subject.retrieve(Pickle::Ref.new("Module::ModelClass \"#{label}\"")).should == model
    end
        
    specify "can be retrieved with Pickle::Ref.new('\"<label>\"')" do
      subject.retrieve(Pickle::Ref.new("\"#{label}\"")).should == model
    end
  end
  
  describe "after storing a model with an optional label," do
    let(:label) { 'label' }
    before { subject.store(model, Pickle::Ref.new('"label"')) }
    
    describe "the model" do
      it_should_behave_like "after storing a model"
      it_should_behave_like "after storing a model with an optional label"
    end
  end
  
  describe "after storing two different models under the same label" do
    before do
      subject.store(model, Pickle::Ref.new('factory "fred"'))
      subject.store(model_class.new, Pickle::Ref.new('factory2 "fred"'))
    end
    
    specify "a model can be retrieved by factory and label" do
      subject.retrieve(Pickle::Ref.new('factory "fred"')).should == model
    end
  
    specify "retrieving by label alone raises Pickle::Jar::AmbiguiousLabelError" do
      lambda { subject.retrieve(Pickle::Ref.new('"fred"')) }.should raise_error(Pickle::Jar::AmbiguiousLabelError)
    end
  end

  describe "after storing 3 models," do
    let(:earliest_model) { model_class.new }
    let(:middle_model) { model_class.new }
    
    before do
      subject.store(earliest_model)
      subject.store(middle_model)
      subject.store(model)
    end
    
    specify "the earliest stored model can be retrieved with '1st' in the pickle ref" do
      subject.retrieve(Pickle::Ref.new("1st module_model_class")).should == earliest_model
    end

    specify "the earliest stored model can be retrieved with 'first' in the pickle ref" do
      subject.retrieve(Pickle::Ref.new("first module_model_class")).should == earliest_model
    end

    specify "the model stored 2nd can be retrieved with '2nd' in the pickle ref" do
      subject.retrieve(Pickle::Ref.new("2nd module_model_class")).should == middle_model
    end

    describe "the latest stored model" do
      it_should_behave_like "after storing a model"
      
      specify "can be retrieved with '3rd' in the pickle ref" do
        subject.retrieve(Pickle::Ref.new("3rd module_model_class")).should == model
      end
    end
    
    specify "attempting to retrieve the 4th model raises UnknownModelError" do
      lambda { subject.retrieve(Pickle::Ref.new("4th module_model_class")) }.should raise_error(Pickle::Jar::UnknownModelError)
    end

    specify "asking if jar #contains? the 4th model returns false" do
      subject.include?(Pickle::Ref.new("4th module_model_class")).should == false
    end
    
    it { should include(Pickle::Ref.new("1st module_model_class")) }
    it { should include(Pickle::Ref.new("2nd module_model_class")) }
    it { should include(Pickle::Ref.new("3rd module_model_class")) }
    it { should_not include(Pickle::Ref.new("25th module_model_class")) }
  end
end
