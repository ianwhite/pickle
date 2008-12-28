require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Parser do
  include Pickle::Parser
        
  describe "Match atoms" do
    def self.atom_should_match(atom, strings)
      Array(strings).each do |string|
        it "#{atom} should match '#{string}'" do
          string.should match(/^#{eval "Pickle::Parser::#{atom}"}$/)
        end
      end
    end

    def self.atom_should_not_match(atom, strings)
      Array(strings).each do |string|
        it "#{atom} should NOT match '#{string}'" do
          string.should_not match(/^#{eval "Pickle::Parser::#{atom}"}$/)
        end
      end
    end
    
    atom_should_match     'Match::Ordinal', ['1st', '2nd', '23rd', '104th']
    atom_should_not_match 'Match::Ordinal', ['1', '2']

    atom_should_match     'Match::Index', ['first', 'last', '23rd', '104th']
    atom_should_not_match 'Match::Index', ['1', '2', 'foo']

    atom_should_match     'Match::Name', [': "gday"', ': "gday mate"']
    atom_should_not_match 'Match::Name', [': "gday""', ': gday']
    
    atom_should_match     'Match::Field', ['foo: "this is the life"', 'bar_man: "and so is this"']
    atom_should_not_match 'Match::Field', ['foo bar: "this aint workin"']
    
    atom_should_match     'Match::Fields', ['foo: "bar"', 'foo: "bar", baz: "bah"']
    atom_should_not_match 'Match::Fields', ['foo bar: "baz"', 'email: "a", password: "b", and password_confirmation: "c"']
  
    atom_should_match     'Match::Model', ['a user', '1st fast car', 'the 23rd fast_car', 'an event_create', 'the 2nd event_create', 'that event create: "zing"']
    atom_should_not_match 'Match::Model', ['a giraffe', 'a 1st faster car: "jim"', 'an event created']
    
    atom_should_match     'Match::ModelName', ['user', 'fast car', 'fast_car', 'event_create', 'event_create', 'event create']
    atom_should_not_match 'Match::ModelName', ['users', 'faster car', 'event created']
  end
  
  describe 'misc regexps' do
    describe '/^(#{Pickle::Parser::Match::Model}) exists/' do
      before do
        @regexp = /^(#{Pickle::Parser::Match::Model}) exists$/
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
      parse_field('a: "b"').should == {'a' => 'b'}
    end
  
    it "should raise error for invalid field 'a : b'" do
      lambda { parse_field('a : b') }.should raise_error(ArgumentError)
    end
  end
  
  describe '#parse_fields' do
    it 'should return {} for blank argument' do
      parse_fields(nil).should == {}
      parse_fields('').should == {}
    end
    
    it 'should raise error for invalid argument' do
      lambda { parse_fields('foo foo') }.should raise_error(ArgumentError)
    end
    
    it '(\'foo: "bar"\') should == { "foo" => "bar"}' do
      parse_fields('foo: "bar"').should == { "foo" => "bar"}
    end
    
    it '(\'foo: "bar", bar_man: "wonga wonga", gump: "123"\') should == {"foo" => "bar", "bar_man" => "wonga wonga", "gump" => "123"}' do
      parse_fields('foo: "bar", bar_man: "wonga wonga", gump: "123"').should == {"foo" => "bar", "bar_man" => "wonga wonga", "gump" => "123"}
    end
  end
  
  describe '#parse_model' do
    it '("a user") should == ["user", ""]' do
      parse_model("a user").should == ["user", ""]
    end

    it '("the user") should == ["user", ""]' do
      parse_model("the user").should == ["user", ""]
    end

    it '("1 fast car") should == ["fast_car", ""]' do
      parse_model("1 fast car").should == ["fast_car", ""]
    end
    
    it '(\'an user: "jim jones"\') should == ["user", "jim_jones"]' do
      parse_model('an user: "jim jones"').should == ["user", "jim_jones"]
    end
    
    it '(\'that fast car: "herbie"\') should == ["fast_car", "herbie"]' do
      parse_model('that fast car: "herbie"').should == ["fast_car", "herbie"]
    end
    
    it '(\'the 12th user\') should == ["user", 11]' do
      parse_model('the 12th user').should == ["user", 11]
    end

    it '(\'the last user\') should == ["user", -1]' do
      parse_model('the last user').should == ["user", -1]
    end
    
    it '("the first user") should == ["user", 0]' do
      parse_model('the first user').should == ["user", 0]
    end

    it '("the 1st user") should == ["user", 0]' do
      parse_model('the 1st user').should == ["user", 0]
    end
  end
  
  describe "#parse_index" do
    it '("1st") should == 0' do
      parse_index("1st").should == 0
    end

    it '("24th") should == 23' do
      parse_index("24th").should == 23
    end
    it '("first") should == 0' do
      parse_index("first").should == 0
    end
    
    it '("last") should == -1' do
      parse_index("last").should == -1
    end
  end
  
  describe "customised mappings" do
    describe 'Pickle::Config.map "I|myself", :to => \'user: "me"\'' do      
      it "'I' should match /\#{Pickle::Parser::Match::Model}/" do
        'I'.should match(/#{Pickle::Parser::Match::Model}/)
      end
      
      it "'myself' should match /\#{Pickle::Parser::Match::Model}/" do
        'myself'.should match(/#{Pickle::Parser::Match::Model}/)
      end
      
      it "parse_the_model_name('I') should == ['user', 'me']" do
        parse_model('I').should == ["user", "me"]
      end
  
      it "parse_the_model_name('myself') should == ['user', 'me']" do
        parse_model('I').should == ["user", "me"]
      end
    end
  end
end