class PickleGenerator < Rails::Generator::Base
  def initialize(args, options)
    super(args, options)
    File.exists?('features/support/env.rb') or raise "features/support/env.rb not found, try running script/generate cucumber"
    @generate_email_steps = args.include?('email')
    if @generate_path_steps = args.include?('path') || args.include?('paths')
      File.exists?('features/support/paths.rb') or raise "features/support/paths.rb not found, is your cucumber up to date?"
    end
  end
  
  def manifest
    record do |m|
      m.directory File.join('features/step_definitions')
      
      current_env = File.read('features/support/env.rb')
      env_assigns = {:current_env => current_env, :pickle => false, :pickle_path => false, :pickle_email => false}
      
      if @generate_path_steps
        env_assigns[:pickle_path] = true unless current_env.include?("require 'pickle/path/world'")
        current_paths = File.read('features/support/paths.rb')
        unless current_paths.include?('#{capture_model}')
          if current_paths =~ /^(.*)(\n\s+else\n\s+raise "Can't find.*".*$)/m
            env_assigns[:current_paths_header] = $1
            env_assigns[:current_paths_footer] = $2
            m.template 'paths.rb', File.join('features/support', "paths.rb"), :assigns => env_assigns, :collision => :force
          end
        end
      end
      
      if @generate_email_steps
        env_assigns[:pickle_email] = true unless current_env.include?("require 'pickle/email/world'")
        m.template 'email_steps.rb', File.join('features/step_definitions', "email_steps.rb") 
      end
      
      env_assigns[:pickle] = true unless current_env.include?("require 'pickle/world'")
      m.template 'pickle_steps.rb', File.join('features/step_definitions', "pickle_steps.rb")
      
      m.template 'env.rb', File.join('features/support', "env.rb"), :assigns => env_assigns, :collision => :force
    end
  end
end