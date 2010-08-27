Given(/^an email "(.*?)" with body: "(.*?)" is delivered to (.+?)$/) do |subject, body, to|
  Notifier.deliver_email(to, subject, body)
end

Given(/^#{capture_model}'s email is delivered$/) do |model|
  Notifier.deliver_user_email(model(model))
end