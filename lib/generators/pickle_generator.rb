require 'rails/generators'

class PickleGenerator < Rails::Generators::Base
  desc "Generates Pickle support and step files."

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
    template "paths.rb", "features/support/paths.rb"
  end

  def copy_email_steps_file
    return unless options.email?
    template "pickle_email_steps.rb", "features/step_definitions/pickle_email_steps.rb"
    template "email.rb", "features/support/email_helper.rb"
  end
end
