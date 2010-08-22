module Pickle
  # register of adapters
  class AdapterMap < Hash
    attr_reader :adapter_classes
    
    def initialize(adapter_classes)
      @adapter_classes = adapter_classes
      create_adapter_map
    end
       
    def reload
      clear
      create_adapter_map
    end
     
  private
    def create_adapter_map
      adapter_classes.reverse do |adapter_class|
        self.merge(adapter_class.adapters.inject({}) {|map, adapter| map.merge(adapter.name => adapter)})
      end
    end
  end
end