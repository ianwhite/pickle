require 'spec_helper'

describe Pickle::Ref do
  describe "(factory) " do
    describe ".new 'colour'" do
      subject { Pickle::Ref.new('colour') }
      
      its(:index)   { should be_nil }
      its(:factory) { should == 'colour' }
      its(:label)   { should be_nil }
    end

    describe "with a prefix" do
      ['a', 'an', 'the', 'that', 'another'].each do |prefix|
        describe ".new '#{prefix} colour'" do
          subject { Pickle::Ref.new("#{prefix} colour") }
        
          its(:factory) { should == 'colour' }
        end
      end
    end
    
    describe ".new 'awesome_colour'" do
      subject { Pickle::Ref.new('awesome_colour') }
      
      its(:factory) { should == 'awesome_colour' }
    end
  end
  
  describe "(index)" do
    describe ".new('1st colour')" do
      subject { Pickle::Ref.new('1st colour') }

      its(:index)   { should == '1st' }
      its(:factory) { should == 'colour' }
      its(:label)   { should be_nil }
      
      ['2nd', 'first', 'last', '3rd', '4th'].each do |index|
        describe ".new('#{index} colour')" do
          subject { Pickle::Ref.new("#{index} colour") }
        
          its(:index) { should == index}
        end
      end
            
      describe "the 2nd colour" do
        subject { Pickle::Ref.new('the 2nd colour') }
        
        its(:index)   { should == '2nd' }
        its(:factory) { should == 'colour' }
      end
    end
    
    describe "(label)" do
      describe "'colour: \"red\"'" do
        subject { Pickle::Ref.new('colour: "red"') }

        its(:index)   { should == nil }
        its(:factory) { should == 'colour' }
        its(:label)   { should == 'red' }
      end
      
      describe "'\"red\"'" do
        subject { Pickle::Ref.new('"red"') }

        its(:index)   { should == nil }
        its(:factory) { should == nil }
        its(:label)   { should == 'red' }
      end
    end
  end
  
  describe "[perverse usage]" do
    describe "superflous content:" do
      ['awesome colour', 'the colour fred', '1st colour gday', 'a'].each do |str|
        describe ".new '#{str}'" do
          subject { Pickle::Ref.new(str) }
          it { lambda { subject }.should raise_error(Pickle::InvalidPickleRefError, /superfluous/) }
        end
      end
    end

    describe "factory or label required:" do
      [''].each do |str|
        describe ".new '#{str}'" do
          subject { Pickle::Ref.new(str) }
          it { lambda { subject }.should raise_error(Pickle::InvalidPickleRefError, /factory or label/) }
        end
      end
    end
    
    describe "can't specify both index and label:" do
      ['1st user "fred"', 'last user: "jim"'].each do |str|
        describe ".new '#{str}'" do
          subject { Pickle::Ref.new(str) }
          it { lambda { subject }.should raise_error(Pickle::InvalidPickleRefError, /can't specify both index and label/) }
        end
      end
    end
  end
end
  