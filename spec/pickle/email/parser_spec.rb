# typed: true
require 'spec_helper'

require 'pickle/email/parser'

describe Pickle::Email::Parser do
  include Pickle::Parser::Matchers
  include Pickle::Email::Parser
  
  describe "#match_email" do
    it "should match 'the email'" do
      expect('the email').to match(/^#{match_email}$/)
    end
    
    it "should match 'the first email'" do
      expect('the first email').to match(/^#{match_email}$/)
    end
    
    it "should match 'the last email'" do
      expect('the last email').to match(/^#{match_email}$/)
    end
    
    it "should match 'the 3rd email'" do
      expect('the 3rd email').to match(/^#{match_email}$/)
    end
    
    it "should match 'an email'" do
      expect('an email').to match(/^#{match_email}$/)
    end
  end
  
  it "#capture_email should just capture match_email" do
    expect(capture_email).to eq("(#{match_email})")
  end
  
  describe "#capture_index_in_email" do
    it "should extract the '2nd' from 'the 2nd email'" do
      match = 'the 2nd email'.match(/^#{capture_index_in_email}$/)
      expect(T.must(match)[1]).to eq('2nd')
    end
    
    it "should extract nil from 'the email'" do
      match = 'the email'.match(/^#{capture_index_in_email}$/)
      expect(T.must(match)[1]).to eq(nil)
    end
    
    it "should extract the 'last' from 'the last email'" do
      match = 'the last email'.match(/^#{capture_index_in_email}$/)
      expect(T.must(match)[1]).to eq('last')
    end
  end
end
