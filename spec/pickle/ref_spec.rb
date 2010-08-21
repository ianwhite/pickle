require 'spec_helper'

describe Pickle::Ref do
  describe "(factory) " do
    shared_examples_for 'pickle ref with :factory => "colour"' do
      its(:index) { should be_nil }
      its(:factory) { should == 'colour' }
      its(:label) { should be_nil }
    end
    
    describe ".new 'colour'" do
      subject { Pickle::Ref.new('colour') }
      it_should_behave_like 'pickle ref with :factory => "colour"'
      
      describe "(prefix)" do
        ['a', 'an', 'the', 'that', 'another'].each do |prefix|
          describe ".new '#{prefix} colour'" do
            subject { Pickle::Ref.new("#{prefix} colour") }
        
            its(:factory) { should == 'colour' }
          end
        end
      end
    end
    
    describe "(:factory => 'colour')" do
      subject { Pickle::Ref.new(:factory => 'colour') }
      it_should_behave_like 'pickle ref with :factory => "colour"'
    end
  end
  
  describe "(index)" do
    shared_examples_for "pickle ref with :factory => 'colour', :index => 0" do
      its(:index) { should == 0 }
      its(:factory) { should == 'colour' }
      its(:label) { should be_nil }
    end

    describe ".new('1st colour')" do
      subject { Pickle::Ref.new('1st colour') }
      
      it_should_behave_like "pickle ref with :factory => 'colour', :index => 0"
      
      {'2nd' => 1, 'first' => 0, 'last' => -1, '3rd' => 2, '4th' => 3}.each do |word, index|
        describe ".new('#{word} colour')" do
          subject { Pickle::Ref.new("#{word} colour") }
        
          its(:index) { should == index}
        end
      end
    end
    
    describe "(:factory => 'colour', :index => 0)" do
      subject { Pickle::Ref.new(:factory => 'colour', :index => 0) }
      
      it_should_behave_like "pickle ref with :factory => 'colour', :index => 0"
    end
    
    describe "the 2nd colour" do
      subject { Pickle::Ref.new('the 2nd colour') }

      its(:index) { should == 1 }
      its(:factory) { should == 'colour' }
    end
  end
  
  describe "(label)" do
    shared_examples_for "pickle ref with :factory => 'colour', :label => 'red'" do
      its(:index)   { should == nil }
      its(:factory) { should == 'colour' }
      its(:label)   { should == 'red' }
    end
    
    describe "'colour: \"red\"'" do
      subject { Pickle::Ref.new('colour: "red"') }
      it_should_behave_like "pickle ref with :factory => 'colour', :label => 'red'"
    end
    
    describe "(:factory => 'colour', :label => 'red')" do
      subject { Pickle::Ref.new(:factory => 'colour', :label => 'red') }
      it_should_behave_like "pickle ref with :factory => 'colour', :label => 'red'"
    end
    
    describe "'\"red\"'" do
      subject { Pickle::Ref.new('"red"') }

      its(:index)   { should == nil }
      its(:factory) { should == nil }
      its(:label)   { should == 'red' }
    end
  end
  
  describe "[perverse usage]" do
    describe "superflous content:" do
      ['awesome colour', 'the colour fred', '1st colour gday', 'a', {:label => 'foo', :blurg => 'bar'}].each do |arg|
        describe ".new #{arg.inspect}" do
          subject { Pickle::Ref.new(arg) }
          it { lambda { subject }.should raise_error(Pickle::InvalidPickleRefError, /superfluous/) }
        end
      end
    end

    describe "factory or label required:" do
      ['', '""', {}, {:index => 2}].each do |arg|
        describe ".new #{arg.inspect}" do
          subject { Pickle::Ref.new(arg) }
          it { lambda { subject }.should raise_error(Pickle::InvalidPickleRefError, /factory or label/) }
        end
      end
    end
    
    describe "can't specify both index and label:" do
      ['1st user "fred"', 'last user: "jim"', {:label => "fred", :index => 0}, {:label => "fred", :factory => "user", :index => -1}].each do |arg|
        describe ".new #{arg.inspect}" do
          subject { Pickle::Ref.new(arg) }
          it { lambda { subject }.should raise_error(Pickle::InvalidPickleRefError, /can't specify both index and label/) }
        end
      end
    end
  end
  
  describe "creating with attrs hash" do
    
  end
end
  