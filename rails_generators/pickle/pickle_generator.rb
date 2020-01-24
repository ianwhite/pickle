# typed: ignore
class PickleGenerator < Rails::Generator::Base
  def initialize(args, options)
    super(args, options)
    @generate_email_steps = args.include?('email')
    @generate_path_steps = args.include?('path')
  end
  
  def manifest
    record do |m|
      m.directory File.join('features/step_definitions')
      m.directory File.join('features/support')
      
      current_pickle = File.exists?('features/support/pickle.rb') ? File.read('features/support/pickle.rb') : ''
      pickle_assigns = {:pickle_path => false, :pickle_email => false}
      
      if @generate_path_steps
        pickle_assigns[:pickle_path] = true
        m.template 'paths.rb', File.join('features/support', 'paths.rb')
      end
      
      if @generate_email_steps
        pickle_assigns[:pickle_email] = true
        m.template 'email_steps.rb', File.join('features/step_definitions', 'email_steps.rb')
        m.template 'email.rb', File.join('features/support', 'email.rb')
      end

      m.template 'pickle_steps.rb', File.join('features/step_definitions', 'pickle_steps.rb')      
      m.template 'pickle.rb', File.join('features/support', 'pickle.rb'), :assigns => pickle_assigns
    end
  end
end
