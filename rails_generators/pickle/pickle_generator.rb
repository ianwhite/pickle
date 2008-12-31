class PickleGenerator < Rails::Generator::Base
  def initialize(*args)
    super(*args)
    File.exists?('features/support/env.rb') or raise "features/support/env.rb not found, try running script/generate cucumber"
  end
  
  def manifest
    record do |m|
      m.directory File.join('features/step_definitions')
      m.template 'pickle_steps.rb', File.join('features/step_definitions', "pickle_steps.rb")
      current_env = File.read('features/support/env.rb')
      if current_env.include?("require 'pickle'")
        logger.skipped "features/support/env.rb, as it already requires pickle"
      else
        m.template 'env.rb', File.join('features/support', "env.rb"), :assigns => {:current_env => current_env}, :collision => :force
      end
    end
  end
end