require 'spec_helper'

describe Pickle::Parser::Matchers do
  include Pickle::Parser::Matchers
  subject { self }
  
  describe "internals" do
    its(:match_quoted) { should match_all '""', '"gday mate"' }
    its(:match_quoted) { should_not match_all '', "''", '"gday \" mate"' }
  
    its(:match_ordinal) { should match_all '1st', '2nd', '23rd', '104th' }
    its(:match_ordinal) { should_not match_any '1', '2' }
  
    its(:match_index) { should match_all 'first', 'last', '23rd', '104th' }
    its(:match_index) { should_not match_any '1', '2', 'foo' }
  
    its(:match_field) { should match_all 'foo: "this is the life"', 'bar_man: "and so is this"', 'boolean: false', 'boolean: true', 'numeric: 10', 'numeric: 12.5', 'numeric: +10', 'numeric: +12.5', 'numeric: -10', 'numeric: -12.5', 'nil_field: nil' }
    its(:match_field) { should_not match_any 'foo bar: "this aint workin"', '"foo": "Bar"', ":foo => bar" }
     
    its(:match_fields) { should match_all 'foo: "bar"', 'foo: "bar", baz: "bah"' }
    its(:match_fields) { should_not match_any 'foo bar: "baz"', 'email: "a", password: "b", and password_confirmation: "c"' }
     
    its(:match_model) { should match_all 'a user', 'another fast_car', 'the 23rd fast_car', '23rd fast_car', 'the user: "fred flinstone"' }
    its(:match_model) { should_not match_any 'another fast car', 'a 1st fast_car', 'the 1st fast_car: "batmobile", ''an event created' }
     
    its(:match_predicate) { should match_all '"a super fun thing"', '"a_fun_thing"' }
    its(:match_predicate) { should_not match_any 'a_fun_thing' }
    
    its(:match_factory) { should match_all 'user', 'fast_car', 'car', 'Car', 'Fast::Car' }
    its(:match_factory) { should_not match_any 'admin users', 'faster car', 'event created' }
  
    its(:match_plural_factory) { should match_all 'users', 'fast_cars', 'cars' }
    its(:match_plural_factory) { should_not match_any 'admin users', 'faster cars', 'events created' }
  
    its(:match_pickle_ref) { should match_all 'a user', 'a user: "fred"', 'the 2nd user', 'the super_admin', '"fred"' }
    its(:match_pickle_ref) { should_not match_any 'another person:', 'another person: ', 'an admin user', 'a 2nd user', '' }
    
    its(:match_value) { should match_all '1', '2.56', 'true', 'false', '-67.7', 'nil' }
    its(:match_value) { should_not match_any '1 1', '2_2.56', 'truthy', '`rm -rf`', 'exec' }
  
    describe "with config.factories = ['admin user', 'funky thing']" do
      before do
        self.config = Pickle::Config.new {|c| c.factories = ["admin user", "funky thing"]}
      end
    
      its(:match_factory) { should match_all 'admin user', 'funky thing' }
      its(:match_factory) { should_not match_any 'admin users', 'funky thong' }
    
      its(:match_plural_factory) { should match_all 'admin users', 'funky things' }
      its(:match_plural_factory) { should_not match_any 'admin user', 'funky thong' }
    end
  
    describe "with config.alias 'external admin', 'admin user', :to => 'external_library_admin_user'" do
      before do
        self.config = Pickle::Config.new {|c| c.alias 'external admin', 'admin user', :to => 'external_library_admin_user'}
      end

      its(:match_factory) { should match_all 'external admin', 'admin user' }
      its(:match_factory) { should_not match_any 'external library admin user' }
    end
  
  
    describe "with config.predicates = ['amazingly large', 'empty']" do
      before do
        self.config = Pickle::Config.new {|c| c.predicates = ['amazingly large', 'empty']}
      end
    
      its(:match_predicate) { should match_all 'amazingly large', 'empty', '"any"' }
      its(:match_predicate) { should_not match_all 'amazingly "large"', 'empty?', 'any' } 
    end
  
    describe "with config.map 'me', 'myself', 'I', :to => 'user \"me\"'" do
      before do
        self.config = Pickle::Config.new {|c| c.map 'me', 'myself', 'I', 'skin coloured bag of bones and meat', :to => 'user "me"' }
      end
    
      its(:match_pickle_ref) { should match_all 'myself', 'me', 'I', 'user: "me"', 'skin coloured bag of bones and meat' }
      its(:match_pickle_ref) { should_not match_any '1st I', 'I "me"', '1st skin coloured bag of bones and meat' }
    end
  end
end