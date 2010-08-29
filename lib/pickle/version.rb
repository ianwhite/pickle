require 'yaml'

module Pickle
  module Version
    Hash = YAML.load_file(File.dirname(__FILE__) + '/../../VERSION.yml')
    Major = Hash[:major]
    Minor = Hash[:minor]
    Patch = Hash[:patch]
    Build = Hash[:build]
    String = "#{Major}.#{Minor}.#{Patch}#{".#{Build}" if Build}"
    
    def self.to_s
      String
    end
  end
end