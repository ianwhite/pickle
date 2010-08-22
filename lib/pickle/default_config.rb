module Pickle
  # include this module to get a config attribute that defaults to Pickle.config if it is not set otherwise
  module DefaultConfig
    attr_writer :config
    
    def config
      @config ||= Pickle.config
    end
  end
end