require 'spec_helper'

describe Pickle::AdapterMap do
  describe ".new" do
    subject { Pickle::AdapterMap.new }
    
    its(:adapter_classes) { should be_empty }
  end
  
  describe ".new <Array of adapter classes>" do
    let(:first_adapter_class) { mock('first adapter class', :adapters => first_adapters) }
    let(:second_adapter_class) { mock('first adapter class', :adapters => second_adapters) }
    let(:first_product_adapter) { mock('first product adapter', :name => 'product') }
    let(:second_user_adapter) { mock('second user adapter', :name => 'user') }
    let(:first_adapters) { [first_product_adapter] }
    let(:second_adapters) { [second_user_adapter] }
    
    subject { Pickle::AdapterMap.new [first_adapter_class, second_adapter_class] }
    
    its(:adapter_classes) { should == [first_adapter_class, second_adapter_class] }
    
    it "values should be the adapters of its adapter classes" do
      subject.values.to_set.should == [first_product_adapter, second_user_adapter].to_set
    end

    it "keys should be the names of the adapters of its adapter classes" do
      subject.keys.to_set.should == ['user', 'product'].to_set
    end
    
    it "should return the correct adapter by [name]" do
      subject['user'].should == second_user_adapter
      subject['product'].should == first_product_adapter
    end
    
    describe "when adapters both define an adapter with the same name" do
      let(:first_user_adapter) { mock('first user adapter', :name => 'user') }
      let(:first_adapters) { [first_product_adapter, first_user_adapter] }
      
      it "['user'] should be the first user adapter" do
        subject['user'].should == first_user_adapter
      end
    end
  end
end
