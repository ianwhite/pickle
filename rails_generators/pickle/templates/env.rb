<%= current_env -%>
<%- if pickle -%>
require 'pickle/world'
# Example of configuring pickle:
#
# Pickle.configure do |config|
#   config.adapters = [:machinist]
#   config.map 'I', 'myself', 'me', 'my', :to => 'user: "me"'
# end
<%- end -%>
<%- if pickle_path -%>require 'pickle/path/world'
<%- end -%>
<%- if pickle_email -%>require 'pickle/email/world'
<%- end -%>