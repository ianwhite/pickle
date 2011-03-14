Given(/^an email "(.*?)" with body: "(.*?)" is delivered to (.+?)$/) do |subject, body, to|
  Notifier.email(to, subject, body).deliver
end

Given(/^#{capture_model}'s email is delivered$/) do |model|
  Notifier.user_email(model!(model)).deliver
end