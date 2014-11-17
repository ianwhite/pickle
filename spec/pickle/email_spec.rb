require 'spec_helper'

require 'pickle/email'
require 'pickle/email/parser'
require 'action_mailer'

describe Pickle::Email do
  include Pickle::Session
  include Pickle::Email
  include Pickle::Email::Parser

  before do
    @email1 = double("Email 1")
    @email2 = double("Email 2")
    allow(ActionMailer::Base).to receive(:deliveries).and_return([@email1, @email2])
    if defined?(ActiveRecord::Base)
      allow(ActiveRecord::Base::PickleAdapter).to receive(:model_classes).and_return([])
    end
  end

  describe "#emails" do
    it "should return ordered deliveries" do
      expect(emails).to eq([@email1, @email2])
    end

    describe "(after)" do
      before do
        emails
      end

      it "#email('the email') should return the last delivery" do
        expect(email('the email')).to eq(@email2)
      end

      it "#email('the 1st email') should return the first delivery" do
        expect(email('the 1st email')).to eq(@email1)
      end

      it "#email('the first email') should return the first delivery" do
        expect(email('the first email')).to eq(@email1)
      end

      it "#email('the 2nd email') should return the second delivery" do
        expect(email('the 2nd email')).to eq(@email2)
      end

      it "#email('the last email') should return the second delivery" do
        expect(email('the last email')).to eq(@email2)
      end

      it "#email2('the 3rd email') should be nil" do
        expect(email('the 3rd email')).to eq(nil)
      end
    end

    describe "when email1 is to fred & joe, and email2 is to joe" do
      before do
        allow(@email1).to receive(:to).and_return(['fred@gmail.com', 'joe@gmail.com'])
        allow(@email2).to receive(:to).and_return('joe@gmail.com')
      end

      it "#emails('to: \"fred@gmail.com\"') should just return email1" do
        expect(emails('to: "fred@gmail.com"')).to eq([@email1])
      end

      describe "after #emails('to: \"fred@gmail.com\"')" do
        before do
          emails('to: "fred@gmail.com"')
        end

        it "#email('first') should be #email('last')" do
          expect(email('first email')).to eq(email('last email'))
          expect(email('first email')).to eq(@email1)
        end

        it "#email('the email', 'to: \"blah\") should be nil" do
          expect(email('the email', 'to: "blah"')).to eq(nil)
        end

        it "#email('the email', 'to: \"fred@gmail.com\") should be email1" do
          expect(email('the email', 'to: "fred@gmail.com"')).to eq(@email1)
        end
      end

      it "#emails('to: \"joe@gmail.com\"') should return both emails" do
        expect(emails('to: "joe@gmail.com"')).to eq([@email1, @email2])
      end

      describe "and emails have subjects 'email1', 'email2'" do
        before do
          allow(@email1).to receive(:subject).and_return('email1')
          allow(@email2).to receive(:subject).and_return('email2')
        end

        it "#emails('to: \"joe@gmail.com\", subject: \"email1\"') should return email1" do
          expect(emails('to: "joe@gmail.com", subject: "email1"')).to eq([@email1])
        end

        it "#emails('to: \"fred@gmail.com\", subject: \"email2\"') should return empty array" do
          expect(emails('to: "fred@gmail.com", subject: "email2"')).to eq([])
        end
      end
    end
  end

  describe "#save_and_open_emails" do
    before do
      allow(self).to receive(:open_in_browser)
      allow(self).to receive(:emails).and_return(["Contents of Email 1"])
      @now = "2008-01-01".to_time
      allow(Time).to receive(:now).and_return(@now)
    end

    it "should call #emails to get emails" do
      expect(self).to receive(:emails).and_return([])
      save_and_open_emails
    end

    describe "when emails have been already been found" do
      before { @emails = [] }

      it "should not call #emails" do
        expect(self).not_to receive(:emails)
        save_and_open_emails
      end
    end

    it "should create a file in Rails/tmp with the emails in it" do
      save_and_open_emails
      expect(File.read("pickle-email-#{@now.to_i}.html")).to eq("<h1>Email 1</h1><pre>Contents of Email 1</pre><hr />")
    end

    it "should call open_in_browser on created tmp file" do
      expect(self).to receive(:open_in_browser).with("pickle-email-#{@now.to_i}.html")
      save_and_open_emails
    end
  end

  describe "following links in emails" do
    let(:body) { 'some text <a href="http://example.com/page">example page</a> more text' }

    before do
      allow(self).to receive(:open_in_browser)
    end

    shared_examples_for 'an email with links' do
      it "should find a link for http://example.com/page" do
        expect(self).to receive(:visit).with('http://example.com/page')
        visit_in_email(@email1, 'http://example.com/page')
      end

      it "should find a link for \"example page\"" do
        expect(self).to receive(:visit).with('http://example.com/page')
        visit_in_email(@email1, 'example page')
      end

      it "should follow the first link in an email" do
        expect(self).to receive(:visit).with('http://example.com/page')
        click_first_link_in_email(@email1)
      end

      it "should not raise an error when the email body is not a string, but needs to_s [#26]" do
        allow(self).to receive(:visit)
        allow(@email1).to receive(:body).and_return(:a_string_body)
        expect { click_first_link_in_email(@email1) }.not_to raise_error
      end
    end

    describe "non multi-part emails" do
      before do
        allow(@email1).to receive(:multipart?).and_return(false)
        allow(@email1).to receive(:body).and_return(body)
      end

      it_behaves_like 'an email with links'
    end

    context "multi-part emails" do
      before do
        allow(@email1).to receive(:multipart?).and_return(true)
        allow(@email1).to receive_message_chain(:html_part, :body).and_return(body)
      end

      it_behaves_like 'an email with links'
    end
  end
end
