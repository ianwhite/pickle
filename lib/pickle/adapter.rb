module Pickle
  # Pickle creates a new adapter instance for each 'factory name' that is used.  The adapter instance has
  # responsibility for making new models, and for finding models.
  #
  # The finding responsibilities are handled by OrmAdapter::AdapterMethods
  #
  # The creating repsonsibilities differ depending on the factory farmework you are using.  Pickle provides:
  #
  # @see pickle/adapters/machinist
  # @see pickle/adapters/factory_girl
  # @see pickle/adapters/orm
  #
  # To create a new adapter:
  #  * it must set @model_class, and @name on initialization
  #  * it must implement the public method #make
  #  * if it is set as a Pickle::Config.adapter_class, then it must implement the class method #adapters that returns all of its adapter instances
  class Adapter
    include OrmAdapter::AdapterMethods
    
    attr_reader :model_class, :name
    
    def make(attributes = {})
      raise NotImplementedError, "return a newly made model"
    end
    
    class << self
      def adapters
        raise NotImplementedError, "return an array of adapter instances"
      end
    end
  end
end