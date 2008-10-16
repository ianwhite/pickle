module Pickle
  module Injector
    def self.inject(session, options = {})
      target = options[:into] || ActionController::Integration::Session
      session_name = session.name.underscore.gsub('/','_')
      
      target.class_eval <<-end_eval, __FILE__, __LINE__
        def #{session_name}
          @#{session_name} ||= #{session.name}.new
        end
      end_eval

      delegate_methods = session.instance_methods - Object.instance_methods
      delegate_methods << {:to => session_name}
      target.delegate *delegate_methods
    end
  end
end