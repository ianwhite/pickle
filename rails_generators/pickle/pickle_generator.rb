class PickleGenerator < Rails::Generator::Base
  def initialize(args, options)
    super(args, options)
    @generate_page_steps = args.include?('page')
    @generate_email_steps = args.include?('email')
    File.exists?('features/support/env.rb') or raise "features/support/env.rb not found, try running script/generate cucumber"
  end
  
  def manifest
    record do |m|
      m.directory File.join('features/step_definitions')
      
      current_env = File.read('features/support/env.rb')
      env_assigns = {:current_env => current_env, :pickle => false, :pickle_page => false, :pickle_email => false}
      
      if @generate_page_steps
        env_assigns[:pickle_page] = true unless current_env.include?("require 'pickle_page'")
        m.template 'pickle_page_steps.rb', File.join('features/step_definitions', "pickle_page_steps.rb") 
      end
      
      if @generate_email_steps
        env_assigns[:pickle_email] = true unless current_env.include?("require 'pickle_email'")
        m.template 'pickle_email_steps.rb', File.join('features/step_definitions', "pickle_email_steps.rb") 
      end
      
      env_assigns[:pickle] = true unless current_env.include?("require 'pickle'")
      m.template 'pickle_steps.rb', File.join('features/step_definitions', "pickle_steps.rb")
      
      m.template 'env.rb', File.join('features/support', "env.rb"), :assigns => env_assigns, :collision => :force
    end
  end
end