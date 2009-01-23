module Pickle
  module Email
    # return the deliveries array, optionally selected by the passed fields
    def emails(fields = nil)
      returning @emails = ActionMailer::Base.deliveries do |emails|
        emails.reject!{|m| !email_matches?(m, fields)} unless fields.blank?
      end
    end

    def email(ref, fields = nil)
      (match = ref.match(/^#{capture_index_in_email}$/)) or raise ArgumentError, "argument should match #{match_email}"
      @emails or raise RuntimeError, "Call #emails before calling #email"
      @emails[parse_index(match[1])]
    end
    
    def email_matches?(email, fields)
    end
    
  protected
    # Saves the emails out to RAILS_ROOT/tmp/ and opens it in the default
    # web browser if on OS X. (depends on webrat)
    def save_and_open_emails
      emails_to_open = @emails || emails
      filename = "#{RAILS_ROOT}/tmp/webrat-email-#{Time.now.to_i}.html"
      File.open(filename, "w") do |f|
        emails_to_open.each_with_index do |e, i|
          f.write "<h1>Email #{i+1}</h1><pre>#{e}</pre><hr />"
        end
      end
      open_in_browser(filename)
    end
  end
end