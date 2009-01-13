<%= current_env %>
<% if pickle %>require 'pickle'<% end %>
<% if pickle_page %>require 'pickle_page'<% end %>
<% if pickle_email %>require 'pickle_email'<% end %>
<% if pickle %>
# Example of configuring pickle:
#
# Pickle.configure do |config|
#   config.adaptors = [:machinist]
#   config.map 'I', 'myself', 'me', 'my', :to => 'user: "me"'
# end
<% end -%>