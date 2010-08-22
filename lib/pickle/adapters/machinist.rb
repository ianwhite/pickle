module Pickle
  class Adapter
    class Machinist < Adapter
      def self.adapters
        adapters = []
        Pickle::OrmAdapter.model_classes.each do |model_class|
          if blueprints = klass.instance_variable_get('@blueprints')
            blueprints.keys.each {|blueprint| adapter << new(model_class, blueprint)}
          end
        end
        adapter
      end

      def initialize(model_class, blueprint)
        @model_class, @blueprint = klass, blueprint
        @name = @model_class.name.underscore.gsub('/','_')
        @name = "#{@blueprint}_#{@name}" unless @blueprint == :master
      end

      def make(attrs = {})
        begin
          @model_class.send(:make!, @blueprint, attrs) # Machinist 2
        rescue
          @model_class.send(:make, @blueprint, attrs)
        end
      end
    end
  end
end