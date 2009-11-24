class PickleGenerator < Rails::Generator::Base
  def initialize(args, options)
    super(args, options)
    @generate_email_steps = args.include?('email')
    if @generate_path_steps = args.include?('path') || args.include?('paths')
      File.exists?('features/support/paths.rb') or raise "features/support/paths.rb not found, is your cucumber up to date?"
    end
  end
  
  def manifest
    record do |m|
      m.directory File.join('features/step_definitions')
      m.directory File.join('features/support')
      
      current_pickle = File.exists?('features/support/pickle.rb') ? File.read('features/support/pickle.rb') : ''
      pickle_assigns = {:pickle_path => false, :pickle_email => false}
      
      if @generate_path_steps
        pickle_assigns[:pickle_path] = true
        current_paths = File.read('features/support/paths.rb')
        unless current_paths.include?('#{capture_model}')
          if current_paths =~ /^(.*)(\n\s+else\n\s+raise "Can't find.*".*$)/m
            pickle_assigns[:current_paths_header] = $1
            pickle_assigns[:current_paths_footer] = $2
            m.template 'paths.rb', File.join('features/support', 'paths.rb'), :assigns => pickle_assigns, :collision => :force
          end
        end
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