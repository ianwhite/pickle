require 'spec_helper'

describe Pickle::Session::Conversion do
  include Pickle::Session::Conversion

  describe "#ref" do
    it "(<hash>) creates a new pickle ref using the hash, and my config" do
      stub!(:config).and_return(mock)
      Pickle::Ref.should_receive(:new).with({:foo => :bar, :config => config}).and_return(pickle_ref = mock)
      ref({:foo => :bar}).should == pickle_ref
    end

    it "(<string>) creates a new pickle ref using the string, and my config" do
      stub!(:config).and_return(mock)
      Pickle::Ref.should_receive(:new).with('foo bar', {:config => config}).and_return(pickle_ref = mock)
      ref('foo bar').should == pickle_ref
    end

    it "(<pickle_ref>) just returns the pickle_ref" do
      pickle_ref = Pickle::Ref.new('factory')
      ref(pickle_ref).should == pickle_ref
    end
  end

  describe "#attributes" do    
    before do
      stub!(:config).and_return(Pickle::Config.new)
    end

    describe "given blank? argument" do
      ['', [], {}, nil, false].each do |arg|
        it "(#{arg.inspect}) should return {}" do
          attributes(arg).should == {}
        end
      end
    end

    describe "given a hash" do
      describe "containing a pickle_ref as a value" do
        let(:do_attributes) { attributes(:name => "Foo", :user => 'a user')}
        let(:model) { mock }

        it "should return a hash containing the retrieved object in place of the pickle ref, and leave other values alone" do
          should_receive(:retrieve).with('a user').and_return(model)
          should_receive(:retrieve).with(anything).and_raise(Pickle::UnknownModelError)
          do_attributes.should == {'name' => "Foo", 'user' => model}
        end
      end
      
      it "should stringify the keys" do
        attributes(:foo => :bar).should == {'foo' => :bar}
      end
      
      it "should not call retrieve unless value is a string" do
        should_not_receive(:retrieve)
        attributes(:foo => :bar)
      end
      
      it "should not call retrieve unless value matches pickle_ref" do
        should_not_receive(:retrieve)
        attributes(:foo => 'a user user user')
      end
    end

    describe "given a string" do
      describe "for example: 'name: \"Fred\", age: 23, married: false, address: nil'" do
        before(:each) do
          stub!(:retrieve).and_raise(Pickle::UnknownModelError)
        end
        let(:do_attributes) { attributes(%q{name: "Fred", description: '  Fred: a great man.  He is what? He is: great ', age: 23, height: 1.95, married: false, address: nil}) }
        subject { do_attributes }

        it { should include('name' => "Fred") }
        it { should include('description' => '  Fred: a great man.  He is what? He is: great ')}
        it { should include('age' => 23) }
        it { should include('height' => 1.95) }
        it { should include('married' => false) }
        it { should include('address' => nil) }
      end

      specify "when field is a pickle-ref which refers attributes should contain it" do
        fred = mock
        should_receive(:retrieve).with('the user "Fred"').and_return fred
        attributes(%q(user: the user "Fred")).should == {'user' => fred}
      end

      specify %Q{when field is a pickle-ref (like 'the user "Fred"') which does not refer it should raise UnknownFieldsFormatError} do
        should_receive(:retrieve).with('the user "Fred"').and_raise(Pickle::UnknownModelError)
        lambda{attributes(%q(user: the user "Fred"))}.should raise_error(Pickle::UnknownFieldsFormatError)
      end

      specify %Q{when field is "Fred" and there is no pickled "Fred" then the attributes should contain the string "Fred"} do
        should_receive(:retrieve).with('"Fred"').and_raise(Pickle::UnknownModelError)
        attributes(%q(user: "Fred")).should == {'user' => "Fred"}
      end

      specify %Q{when field is "Fred" and there is a pickled "Fred" then the attributes should contain the fred object} do
        should_receive(:retrieve).with('"Fred"').and_return fred = mock
        attributes(%q(user: "Fred")).should == {'user' => fred}
      end
    end
    it %Q{when trying to specify the string "Fred" for a string attribute a model named fred is inserted instead, what to do??}
  end
  
  describe "#value(<string>)" do
    describe "when <string> is a pickle ref that is known" do
      let(:fred) {mock}
      before { should_receive(:retrieve).with('"Fred"').and_return(fred) }
      
      it "should return a the referred to model" do
        value('"Fred"').should == fred
      end
    end
    
    describe "when <string> is a pickle ref that is not known" do
      before do
        should_receive(:retrieve).with('"Fred"').and_raise(Pickle::UnknownModelError)
      end

      it "should parse <stirng> as a value" do
        value('"Fred"').should == "Fred"
      end
    end
  end
end