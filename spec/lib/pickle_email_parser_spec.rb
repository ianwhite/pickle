require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Email::Parser do
  include Pickle::Parser::Matchers
  include Pickle::Email::Parser
  
  describe "#match_email" do
    it "should match 'the email'" do
      'the email'.should match(/^#{match_email}$/)
    end
    
    it "should match 'the first email'" do
      'the first email'.should match(/^#{match_email}$/)
    end
    
    it "should match 'the last email'" do
      'the last email'.should match(/^#{match_email}$/)
    end
    
    it "should match 'the 3rd email'" do
      'the 3rd email'.should match(/^#{match_email}$/)
    end
    
    it "should match 'an email'" do
      'an email'.should match(/^#{match_email}$/)
    end
  end
  
  it "#capture_email should just capture match_email" do
    capture_email.should == "(#{match_email})"
  end
  
  describe "#capture_index_in_email" do
    it "should extract the '2nd' from 'the 2nd email'" do
      match = 'the 2nd email'.match(/^#{capture_index_in_email}$/)
      match[1].should == '2nd'
    end
    
    it "should extract nil from 'the email'" do
      match = 'the email'.match(/^#{capture_index_in_email}$/)
      match[1].should == nil
    end
    
    it "should extract the 'last' from 'the last email'" do
      match = 'the last email'.match(/^#{capture_index_in_email}$/)
      match[1].should == 'last'
    end
  end
end