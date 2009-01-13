module Pickle
  module Email
    # return the deliveris array, or a particlar email
    def emails(fields = nil)
      @emails = ActionMailer::Base.deliveries
      @emails = @emails.select{|m| m.to == Array(to)} unless to.nil?
    end

    def email(ref)

    end

  protected
    # Saves the emails out to RAILS_ROOT/tmp/ and opens it in the default
    # web browser if on OS X. (depends on webrat)
    def save_and_open_emails
      filename = "#{RAILS_ROOT}/tmp/webrat-email-#{Time.now.to_i}.html"
      File.open(filename, "w") do |f|
        emails.each_with_index do |e, i|
          f.write "<h1>Email #{i+1}</h1><pre>#{e}</pre><hr />"
        end
      end
      open_in_browser(filename)
    end
  end
end