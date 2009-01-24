require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Email do
  include Pickle::Session
  include Pickle::Email
  include Pickle::Email::Parser

  before do
    @email1 = mock("Email 1")
    @email2 = mock("Email 2")
    ActionMailer::Base.stub!(:deliveries).and_return([@email1, @email2])
  end
  
  describe "#emails" do
    it "should return ordered deliveries" do
      emails.should == [@email1, @email2]
    end
    
    describe "(after)" do
      before do
        emails
      end
      
      it "#email('the email') should return the last delivery" do
        email('the email').should == @email2
      end
      
      it "#email('the 1st email') should return the first delivery" do
        email('the 1st email').should == @email1
      end

      it "#email('the first email') should return the first delivery" do
        email('the first email').should == @email1
      end

      it "#email('the 2nd email') should return the second delivery" do
        email('the 2nd email').should == @email2
      end
      
      it "#email('the last email') should return the second delivery" do
        email('the last email').should == @email2
      end
      
      it "#email2('the 3rd email') should be nil" do
        email('the 3rd email').should == nil
      end
    end
    
    describe "when email1 is to fred & joe, and email2 is to joe" do
      before do
        @email1.stub!(:to).and_return(['fred@gmail.com', 'joe@gmail.com'])
        @email2.stub!(:to).and_return('joe@gmail.com')
      end
      
      it "#emails('to: \"fred@gmail.com\"') should just return email1" do
        emails('to: "fred@gmail.com"').should == [@email1]
      end
      
      describe "after #emails('to: \"fred@gmail.com\"')" do
        before do
          emails('to: "fred@gmail.com"')
        end
        
        it "#email('first') should be #email('last')" do
          email('first email').should == email('last email')
          email('first email').should == @email1
        end
        
        it "#email('the email', 'to: \"blah\") should be nil" do
          email('the email', 'to: "blah"').should == nil
        end

        it "#email('the email', 'to: \"fred@gmail.com\") should be email1" do
          email('the email', 'to: "fred@gmail.com"').should == @email1
        end
      end
      
      it "#emails('to: \"joe@gmail.com\"') should return both emails" do
        emails('to: "joe@gmail.com"').should == [@email1, @email2]
      end
      
      describe "and emails have subjects 'email1', 'email2'" do
        before do
          @email1.stub!(:subject).and_return('email1')
          @email2.stub!(:subject).and_return('email2')
        end
        
        it "#emails('to: \"joe@gmail.com\", subject: \"email1\"') should return email1" do
          emails('to: "joe@gmail.com", subject: "email1"').should == [@email1]
        end
        
        it "#emails('to: \"fred@gmail.com\", subject: \"email2\"') should return empty array" do
          emails('to: "fred@gmail.com", subject: "email2"').should == []
        end
      end
    end
  end
  
  describe "#save_and_open_emails" do
    before do
      stub!(:open_in_browser)
      stub!(:emails).and_return(["Contents of Email 1"])
      @now = "2008-01-01".to_time
      Time.stub!(:now).and_return(@now)
    end
    
    it "should call #emails to get emails" do
      should_receive(:emails).and_return([])
      save_and_open_emails
    end
    
    describe "when emails have been already been found" do
      before { @emails = [] }
      
      it "should not call #emails" do
        should_not_receive(:emails)
        save_and_open_emails
      end
    end
    
    it "should create a file in Rails/tmp with the emails in it" do
      save_and_open_emails
      File.read("#{RAILS_ROOT}/tmp/webrat-email-#{@now.to_i}.html").should == "<h1>Email 1</h1><pre>Contents of Email 1</pre><hr />"
    end

    it "should call open_in_browser on created tmp file" do
      should_receive(:open_in_browser).with("#{RAILS_ROOT}/tmp/webrat-email-#{@now.to_i}.html")
      save_and_open_emails
    end
  end
end