module Pickle
  module Injector
    def self.inject(delegate_class, options = {})
      target_class  = options[:into] || raise('inject requires a target class specified with :into')
      delegate_name = options[:name] || delegate_class.name.underscore.gsub('/','_')
      init_delegate = options[:init] || lambda { new }
      
      # create a session object on demand (in target)
      target_class.send(:define_method, delegate_name) do
        instance_variable_get("@#{delegate_name}") || instance_variable_set("@#{delegate_name}", delegate_class.instance_eval(&init_delegate))
      end
      
      # in the target, delegate the public instance methods of delegate_class to the delegate_name method
      delegate_methods = delegate_class.public_instance_methods - Object.instance_methods
      target_class.delegate *(delegate_methods + [{:to => delegate_name}])
    end
  end
end