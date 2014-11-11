Given(/^an email "(.*?)" with body: "(.*?)" is delivered to (.+?)$/) do |subject, body, to|
  Notifier.email(to, subject, body).deliver
end

Given(/^an email with a link "(.+?)" to (.+?) is delivered to (.+?)$/) do |text, page, to|
  body = "some text <a href='http://example.com/#{path_to(page)}'>#{text}</a> more text" 
  Notifier.email(to, "example", body).deliver
end

Given(/^#{capture_model}'s email is delivered$/) do |model|
  Notifier.user_email(model!(model)).deliver
end