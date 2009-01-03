require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Parser::Matchers do
  include Pickle::Parser::Matchers

  describe "(config: [factories: user, car, fast_car] [predicates: name, status, fancy?, super_fancy?]" do
    def config
      @config ||= Pickle::Config.new do |c|
        c.factories = {
          'user'      => mock('factory'),
          'car'       => mock('factory'),
          'fast_car'  => mock('factory')
        }
        c.predicates = %w(name status fancy? super_fancy?)
      end
    end
  
    describe "Match atoms" do
      def self.atom_should_match(atom, strings)
        Array(strings).each do |string|
          it "#{atom} should match '#{string}'" do
            string.should match(/^#{send atom}$/)
          end
        end
      end

      def self.atom_should_not_match(atom, strings)
        Array(strings).each do |string|
          it "#{atom} should NOT match '#{string}'" do
            string.should_not match(/^#{send atom}$/)
          end
        end
      end
  
      atom_should_match     :match_ordinal, ['1st', '2nd', '23rd', '104th']
      atom_should_not_match :match_ordinal, ['1', '2']

      atom_should_match     :match_index, ['first', 'last', '23rd', '104th']
      atom_should_not_match :match_index, ['1', '2', 'foo']

      atom_should_match     :match_label, [': "gday"', ': "gday mate"']
      atom_should_not_match :match_label, [': "gday""', ': gday']
  
      atom_should_match     :match_field, ['foo: "this is the life"', 'bar_man: "and so is this"', 'boolean: false', 'boolean: true', 'numeric: 10', 'numeric: 12.5']
      atom_should_not_match :match_field, ['foo bar: "this aint workin"']
  
      atom_should_match     :match_fields, ['foo: "bar"', 'foo: "bar", baz: "bah"']
      atom_should_not_match :match_fields, ['foo bar: "baz"', 'email: "a", password: "b", and password_confirmation: "c"']

      atom_should_match     :match_model, ['a user', '1st fast car', 'the 23rd fast_car', 'the user: "fred flinstone"']
      atom_should_not_match :match_model, ['a giraffe', 'a 1st faster car: "jim"', 'an event created']
  
      atom_should_match     :match_predicate, ['name', 'status', 'fancy', 'super fancy', 'super_fancy']
      atom_should_not_match :match_predicate, ['nameo', 'increment', 'not a predicate']
    
      atom_should_match     :match_factory, ['user', 'fast car', 'fast_car', 'car']
      atom_should_not_match :match_factory, ['users', 'faster car', 'event created']
    
      atom_should_match     :match_plural_factory, ['users', 'fast cars']
      atom_should_not_match :match_plural_factory, ['usereres', 'fasts cars']
    end
  end
  
  describe "capture methods" do
    it "capture_field should == '(' + match_field + ')'" do
      should_receive(:match_field).and_return('MATCH_FIELD')
      capture_field.should == '(MATCH_FIELD)'
    end
  end
end