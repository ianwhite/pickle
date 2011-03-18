module Pickle
  module Email
    # return the deliveries array, optionally selected by the passed fields
    def emails(fields = nil)
      @emails = ActionMailer::Base.deliveries.select {|m| email_has_fields?(m, fields)}
    end

    def email(ref, fields = nil)
      (match = ref.match(/^#{capture_index_in_email}$/)) or raise ArgumentError, "argument should match #{match_email}"
      @emails or raise RuntimeError, "Call #emails before calling #email"
      index = parse_index(match[1])
      email_has_fields?(@emails[index], fields) ? @emails[index] : nil
    end

    def email_has_fields?(email, fields)
      parse_fields(fields).each do |key, val|
        return false unless (Array(email.send(key)) & Array(val)).any?
      end
      true
    end

    def visit_in_email(email, link_text)
      visit(parse_email_for_link(email, link_text))
    end

    def click_first_link_in_email(email)
      link = links_in_email(email).first
      visit link
    end

  protected
    def open_in_browser(path) # :nodoc
      require "launchy"
      Launchy::Browser.run(path)
    rescue LoadError
      warn "Sorry, you need to install launchy to open emails: `gem install launchy`"
    end

    # Saves the emails out to RAILS_ROOT/tmp/ and opens it in the default
    # web browser if on OS X. (depends on webrat)
    def save_and_open_emails
      emails_to_open = @emails || emails
      filename = "pickle-email-#{Time.now.to_i}.html"
      File.open(filename, "w") do |f|
        emails_to_open.each_with_index do |e, i|
          f.write "<h1>Email #{i+1}</h1><pre>#{e}</pre><hr />"
        end
      end
      open_in_browser(filename)
    end

    def parse_email_for_link(email, text_or_regex)
      url = parse_email_for_explicit_link(email, text_or_regex)
      url ||= parse_email_for_anchor_text_link(email, text_or_regex)
      raise "No link found matching #{text_or_regex.inspect} in #{email}" unless url
      url
    end

    # e.g. confirm in http://confirm
    def parse_email_for_explicit_link(email, regex)
      regex = /#{Regexp.escape(regex)}/ unless regex.is_a?(Regexp)
      links_in_email(email).detect { |link| link =~ regex }
    end

    # e.g. Click here in  <a href="http://confirm">Click here</a>
    def parse_email_for_anchor_text_link(email, link_text)
      if email.multipart?
        body = email.html_part.body
      else
        body = email.body
      end
      if match_data = body.match(%r{<a[^>]*href=['"]?([^'"]*)['"]?[^>]*?>[^<]*?#{link_text}[^<]*?</a>})
        match_data[1]
      end
    end

    def links_in_email(email, protos=['http', 'https'])
      if email.multipart?
        body = email.html_part.body
      else
        body = email.body
      end
      URI.extract(body.to_s, protos)
    end

  end
end
