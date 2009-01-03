require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Parser do
  before do
    @parser = Pickle::Parser.new(:config => Pickle::Config.new)
  end
  
  it "should raise error when created with no config" do
    lambda{ Pickle::Parser.new }.should raise_error(ArgumentError)
  end
  
  describe 'misc regexps' do
    describe '/^#{capture_model} exists/' do
      before do
        @regexp = /^(#{@parser.capture_model}) exists$/
      end
      
      it "should match 'a user exists'" do
        'a user exists'.should match(@regexp)
      end
      
      it "should caputure 'a user' from  'a user exists'" do
        'a user exists'.match(@regexp)[1].should == 'a user'
      end
    end
  end
  
  describe '#parse_field' do
    it "should return {'a' => 'b'} for 'a: \"b\"'" do
      @parser.parse_field('a: "b"').should == {'a' => 'b'}
    end
  
    it "should raise error for invalid field 'a : b'" do
      lambda { @parser.parse_field('a : b') }.should raise_error(ArgumentError)
    end
  end
  
  describe '#parse_fields' do
    it 'should return {} for blank argument' do
      @parser.parse_fields(nil).should == {}
      @parser.parse_fields('').should == {}
    end
    
    it 'should raise error for invalid argument' do
      lambda { @parser.parse_fields('foo foo') }.should raise_error(ArgumentError)
    end
    
    it '(\'foo: "bar"\') should == { "foo" => "bar"}' do
      @parser.parse_fields('foo: "bar"').should == { "foo" => "bar"}
    end
    
    it '("bool: true") should == { "bool" => true}' do
      @parser.parse_fields('bool: true').should == {"bool" => true}
    end
    
    it '("bool: false") should == { "bool" => false}' do
      @parser.parse_fields('bool: false').should == {"bool" => false}
    end
    
    it '("int: 10") should == { "int" => 10 }' do
      @parser.parse_fields('int: 10').should == {"int" => 10}
    end

    it '("float: 10.1") should == { "float" => 10.1 }' do
      @parser.parse_fields('float: 10.1').should == {"float" => 10.1}
    end

    it '(\'foo: "bar", bar_man: "wonga wonga", gump: 123\') should == {"foo" => "bar", "bar_man" => "wonga wonga", "gump" => 123}' do
      @parser.parse_fields('foo: "bar", bar_man: "wonga wonga", gump: 123').should == {"foo" => "bar", "bar_man" => "wonga wonga", "gump" => 123}
    end
  end
  
  describe '#parse_model' do
    it '("a user") should == ["user", ""]' do
      @parser.parse_model("a user").should == ["user", ""]
    end
  
    it '("the user") should == ["user", ""]' do
      @parser.parse_model("the user").should == ["user", ""]
    end
  
    it '("1 fast car") should == ["fast_car", ""]' do
      @parser.parse_model("1 fast car").should == ["fast_car", ""]
    end
    
    it '(\'an user: "jim jones"\') should == ["user", "jim_jones"]' do
      @parser.parse_model('an user: "jim jones"').should == ["user", "jim_jones"]
    end
    
    it '(\'that fast car: "herbie"\') should == ["fast_car", "herbie"]' do
      @parser.parse_model('that fast car: "herbie"').should == ["fast_car", "herbie"]
    end
    
    it '(\'the 12th user\') should == ["user", 11]' do
      @parser.parse_model('the 12th user').should == ["user", 11]
    end
  
    it '(\'the last user\') should == ["user", -1]' do
      @parser.parse_model('the last user').should == ["user", -1]
    end
    
    it '("the first user") should == ["user", 0]' do
      @parser.parse_model('the first user').should == ["user", 0]
    end
  
    it '("the 1st user") should == ["user", 0]' do
      @parser.parse_model('the 1st user').should == ["user", 0]
    end
  end
  
  describe "#parse_index" do
    it '("1st") should == 0' do
      @parser.parse_index("1st").should == 0
    end
  
    it '("24th") should == 23' do
      @parser.parse_index("24th").should == 23
    end
    it '("first") should == 0' do
      @parser.parse_index("first").should == 0
    end
    
    it '("last") should == -1' do
      @parser.parse_index("last").should == -1
    end
  end
  
  describe "customised mappings" do
    describe "config maps 'I|myself' to 'user: \"me\"'" do
      before do
        @config = Pickle::Config.new do |c|
          c.map 'I', 'myself', :to => 'user: "me"'
        end
        @parser = Pickle::Parser.new(:config => @config)
      end

      it "'I' should match /\#{match_model}/" do
        'I'.should match(/#{@parser.match_model}/)
      end
    
      it "'myself' should match /\#{match_model}/" do
        'myself'.should match(/#{@parser.match_model}/)
      end
    
      it "parse_model('I') should == ['user', 'me']" do
        @parser.parse_model('I').should == ["user", "me"]
      end

      it "parse_model('myself') should == ['user', 'me']" do
        @parser.parse_model('myself').should == ["user", "me"]
      end
    end
  end
end