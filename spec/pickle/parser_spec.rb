# typed: ignore
require 'spec_helper'

describe Pickle::Parser do
  before do
    @parser = Pickle::Parser.new(:config => Pickle::Config.new)
  end
  
  it "should raise error when created with no config" do
    expect{ Pickle::Parser.new }.to raise_error(ArgumentError)
  end
  
  describe "when a 'user' factory exists in config" do
    before do
      allow(@parser.config).to receive(:factories).and_return('user' => double('User'))
    end
    
    describe 'misc regexps' do
      describe '/^#{capture_model} exists/' do
        before do
          @regexp = /^(#{@parser.capture_model}) exists$/
        end
      
        it "should match 'a user exists'" do
          expect('a user exists').to match(@regexp)
        end
      
        it "should caputure 'a user' from  'a user exists'" do
          expect('a user exists'.match(@regexp)[1]).to eq('a user')
        end
      end
    end
  
    describe '#parse_field' do
      it "should return {'a' => 'b'} for 'a: \"b\"'" do
        expect(@parser.parse_field('a: "b"')).to eq({'a' => 'b'})
      end
  
      it "should raise error for invalid field 'a : b'" do
        expect { @parser.parse_field('a : b') }.to raise_error(ArgumentError)
      end
    end
  
    describe '#parse_fields' do
      it 'should return {} for blank argument' do
        expect(@parser.parse_fields(nil)).to eq({})
        expect(@parser.parse_fields('')).to eq({})
      end
    
      it 'should raise error for invalid argument' do
        expect { @parser.parse_fields('foo foo') }.to raise_error(ArgumentError)
      end
    
      it '(\'foo: "bar"\') should == { "foo" => "bar"}' do
        expect(@parser.parse_fields('foo: "bar"')).to eq({ "foo" => "bar"})
      end

      it '(\'foo: "something \"quoted\""\') should == { "foo" => "bar"}' do
        expect(@parser.parse_fields('foo: "something \"quoted\""')).to eq({ "foo" => 'something "quoted"' })
      end
    
      it '("bool: true") should == { "bool" => true}' do
        expect(@parser.parse_fields('bool: true')).to eq({"bool" => true})
      end
    
      it '("bool: false") should == { "bool" => false}' do
        expect(@parser.parse_fields('bool: false')).to eq({"bool" => false})
      end
    
      it '("int: 10") should == { "int" => 10 }' do
        expect(@parser.parse_fields('int: 10')).to eq({"int" => 10})
      end

      it '("float: 10.1") should == { "float" => 10.1 }' do
        expect(@parser.parse_fields('float: 10.1')).to eq({"float" => 10.1})
      end

      it '(\'foo: "bar", bar_man: "wonga wonga", baz_woman: "one \"two\" three", gump: 123\') should == {"foo" => "bar", "bar_man" => "wonga wonga", "gump" => 123}' do
        expect(@parser.parse_fields('foo: "bar", bar_man: "wonga wonga", baz_woman: "one \"two\" three", gump: 123')).to eq({"foo" => "bar", "bar_man" => "wonga wonga", "baz_woman" => "one \"two\" three", "gump" => 123})
      end
    end
  
    describe '#parse_model' do
      it '("a user") should == ["user", ""]' do
        expect(@parser.parse_model("a user")).to eq(["user", ""])
      end
  
      it '("the user") should == ["user", ""]' do
        expect(@parser.parse_model("the user")).to eq(["user", ""])
      end
  
      it '("1 user") should == ["user", ""]' do
        expect(@parser.parse_model("1 user")).to eq(["user", ""])
      end
    
      it '(\'an user: "jim jones"\') should == ["user", "jim_jones"]' do
        expect(@parser.parse_model('an user: "jim jones"')).to eq(["user", "jim_jones"])
      end
    
      it '(\'that user: "herbie"\') should == ["user", "herbie"]' do
        expect(@parser.parse_model('that user: "herbie"')).to eq(["user", "herbie"])
      end
    
      it '(\'the 12th user\') should == ["user", 11]' do
        expect(@parser.parse_model('the 12th user')).to eq(["user", 11])
      end
  
      it '(\'the last user\') should == ["user", -1]' do
        expect(@parser.parse_model('the last user')).to eq(["user", -1])
      end
    
      it '("the first user") should == ["user", 0]' do
        expect(@parser.parse_model('the first user')).to eq(["user", 0])
      end
  
      it '("the 1st user") should == ["user", 0]' do
        expect(@parser.parse_model('the 1st user')).to eq(["user", 0])
      end
    end
  
    describe "#parse_index" do
      it '("1st") should == 0' do
        expect(@parser.parse_index("1st")).to eq(0)
      end
  
      it '("24th") should == 23' do
        expect(@parser.parse_index("24th")).to eq(23)
      end
      it '("first") should == 0' do
        expect(@parser.parse_index("first")).to eq(0)
      end
    
      it '("last") should == -1' do
        expect(@parser.parse_index("last")).to eq(-1)
      end
    end
  end

  describe "customised mappings" do
    describe "config maps 'I|myself' to 'user: \"me\"'" do
      before do
        @config = Pickle::Config.new do |c|
          c.map 'I', 'myself', :to => 'user: "me"'
        end
        @parser = Pickle::Parser.new(:config => @config)
        allow(@parser.config).to receive(:factories).and_return('user' => double('User'))
      end

      it "'I' should match /\#{match_model}/" do
        expect('I').to match(/#{@parser.match_model}/)
      end
  
      it "'myself' should match /\#{match_model}/" do
        expect('myself').to match(/#{@parser.match_model}/)
      end
  
      it "parse_model('I') should == ['user', 'me']" do
        expect(@parser.parse_model('I')).to eq(["user", "me"])
      end

      it "parse_model('myself') should == ['user', 'me']" do
        expect(@parser.parse_model('myself')).to eq(["user", "me"])
      end
    end
  end
end