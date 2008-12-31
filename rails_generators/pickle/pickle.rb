class PickleGenerator < Rails::Generator::Base
  def initialize(*args)
    super(*args)
    File.exists?('features/support/env.rb') or raise "features/support/env.rb not found, try running script/generate cucumber"
  end
  
  def manifest
    record do |m|
      m.directory File.join('features/step_definitions')
      m.template 'pickle_steps.rb', File.join('features/step_definitions', "pickle_steps.rb")
    end
  end
end