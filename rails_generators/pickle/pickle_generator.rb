class PickleGenerator < Rails::Generator::Base
  def initialize(args, options)
    super(args, options)
    @generate_path_steps = args.include?('page') || args.include?('path')
    @generate_email_steps = args.include?('email')
    File.exists?('features/support/env.rb') or raise "features/support/env.rb not found, try running script/generate cucumber"
  end
  
  def manifest
    record do |m|
      m.directory File.join('features/step_definitions')
      
      current_env = File.read('features/support/env.rb')
      env_assigns = {:current_env => current_env, :pickle => false, :pickle_path => false, :pickle_email => false}
      
      if @generate_path_steps
        env_assigns[:pickle_path] = true unless current_env.include?("require 'pickle/path/world'")
        m.template 'pickle_path_steps.rb', File.join('features/step_definitions', "pickle_path_steps.rb") 
      end
      
      if @generate_email_steps
        env_assigns[:pickle_email] = true unless current_env.include?("require 'pickle/email/world'")
        m.template 'pickle_email_steps.rb', File.join('features/step_definitions', "pickle_email_steps.rb") 
      end
      
      env_assigns[:pickle] = true unless current_env.include?("require 'pickle/world'")
      m.template 'pickle_steps.rb', File.join('features/step_definitions', "pickle_steps.rb")
      
      m.template 'env.rb', File.join('features/support', "env.rb"), :assigns => env_assigns, :collision => :force
    end
  end
end