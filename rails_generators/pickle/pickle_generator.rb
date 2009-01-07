class PickleGenerator < Rails::Generator::Base
  def initialize(args, options)
    super(args, options)
    @generate_page_steps = args.include?('page')
    File.exists?('features/support/env.rb') or raise "features/support/env.rb not found, try running script/generate cucumber"
  end
  
  def manifest
    record do |m|
      m.directory File.join('features/step_definitions')
      
      current_env = File.read('features/support/env.rb')
      if current_env.include?("require 'pickle'")
        logger.skipped "features/support/env.rb, as it already requires pickle"
      else
        m.template 'env.rb', File.join('features/support', "env.rb"), :assigns => {:current_env => current_env}, :collision => :force
      end
      
      m.template 'pickle_steps.rb', File.join('features/step_definitions', "pickle_steps.rb")
      m.template 'page_steps.rb', File.join('features/step_definitions', "page_steps.rb") if @generate_page_steps
    end
  end
end