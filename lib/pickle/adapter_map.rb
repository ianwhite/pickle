module Pickle
  # register of adapters
  class AdapterMap < Hash
    attr_reader :adapter_classes
    
    def initialize(adapter_classes = [])
      @adapter_classes = adapter_classes
      create_adapter_map
    end
       
    def reload
      create_adapter_map
      self
    end
     
  private
    def create_adapter_map
      adapter_classes.reverse.each do |adapter_class|
        adapters = adapter_class.adapters.inject({}) do |adapter_map, adapter|
          adapter_map.merge(adapter.name.to_s => adapter)
        end
        merge! adapters
      end
    end
  end
end