module Pickle
  module Injector
    def self.inject(session_class, options = {})
      target = options[:into] || ActionController::Integration::Session
      session_method = options[:name] || session_class.name.underscore.gsub('/','_')
      session_options = options[:options] || {}
      
      # create a session object on demand (in target)
      target.send(:define_method, session_method) do
        instance_variable_get("@#{session_method}") || instance_variable_set("@#{session_method}", session_class.new(session_options))
      end
      
      # delegate session methods to the session object (in target)
      delegate_methods = session_class.public_instance_methods - Object.instance_methods
      target.delegate *(delegate_methods + [{:to => session_method}])
    end
  end
end