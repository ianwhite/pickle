require 'rails/generators'

class PickleGenerator < Rails::Generators::Base
  desc "Generates Pickle step files."

  # Use the same templates as Rails 2 generator
  source_root File.expand_path("../../../rails_generators/pickle/templates", __FILE__)

  class_option :paths, :desc => "Generate features/support/paths.rb file.", :type => :boolean
  class_option :email, :desc => "Generate features/step_definitions/email_steps.rb file", :type => :boolean

  def initialize(args = [], options = {}, config = {})
    super

    if self.options.paths? && !File.exists?("features/support/paths.rb")
      say "features/support/paths.rb not found, is your cucumber up to date?", :red
      exit
    end
  end

  def create_directories
    empty_directory "features/step_definitions"
    empty_directory "features/support"
  end

  def copy_pickle_steps_file
    template "pickle_steps.rb", "features/step_definitions/pickle_steps.rb"
    template "pickle.rb", "features/support/pickle.rb"
  end

  def copy_paths_file
    return unless options.paths?

    current_paths = File.read("features/support/paths.rb")
    unless current_paths.include?('#{capture_model}')
      if current_paths =~ /^(.*)(\n\s+else\n\s+raise "Can't find.*".*$)/m
        @current_paths_header = $1
        @current_paths_footer = $2
      end
      template "paths.rb", "features/support/paths.rb"
    end
  end

  def copy_email_steps_file
    return unless options.email?
    template "email_steps.rb", "features/step_definitions/email_steps.rb"
    template "email.rb", "features/support/email.rb"
  end


  private

  # Compatibility methods for Rails 2 templates
  def pickle_path
    options.paths?
  end

  def pickle_email
    options.email?
  end

  def current_paths_header
    @current_paths_header
  end

  def current_paths_footer
    @current_paths_footer
  end
end
