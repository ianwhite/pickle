module Pickle
  class ModelNotKnownError < RuntimeError
    attr_reader :name
    
    def initialize(name, message = nil)
      @name = name
      @message = message || "The model: '#{name}' is not known in this scenario.  Use #create_model to create, or #find_model to find, and store a reference in this scenario."
    end
    
    def to_s
      @message
    end
  end
  
  module Session
    class << self
      def included(world_class)
        proxy_to_pickle_parser(world_class)
      end
      
      def extended(world_object)
        proxy_to_pickle_parser(class << world_object; self; end) # metaclass is not 2.1 compatible
      end
      
    protected
      def proxy_to_pickle_parser(world_class)
        world_class.class_eval do
          unless methods.include?('method_missing_with_pickle_parser')
            alias_method_chain :method_missing, :pickle_parser
            alias_method_chain :respond_to?, :pickle_parser
          end
        end
      end
    end
    
    def create_model(pickle_ref, fields = nil)
      factory, label = *parse_model(pickle_ref)
      raise ArgumentError, "Can't create with an ordinal (e.g. 1st user)" if label.is_a?(Integer)
      fields = fields.is_a?(Hash) ? parse_hash(fields) : parse_fields(fields)
      record = pickle_config.factories[factory].create(fields)
      store_model(factory, label, record)
      record
    end
    
    # if a column exists in the table which matches the singular factory name, this is used as the pickle ref
    def create_models_from_table(plural_factory, table)
      factory = plural_factory.singularize
      table.hashes.map do |hash|
        pickle_ref = factory + (hash[factory] ? " \"#{hash.delete(factory)}\"" : "")
        create_model(pickle_ref, hash)
      end
    end

    def find_model(a_model_name, fields = nil)
      factory, name = *parse_model(a_model_name)

      raise ArgumentError, "Can't find a model with an ordinal (e.g. 1st user)" if name.is_a?(Integer)

      model_class = pickle_config.factories[factory].klass
      fields      = fields.is_a?(Hash) ? parse_hash(fields) : parse_fields(fields)
      conditions  = convert_models_to_attributes(model_class, fields)
      record      = Pickle::Adapter.find_first_model(model_class, conditions)

      store_model(factory, name, record) if record

      record
    end
    
    def find_model!(name, fields = nil)
      find_model(name, fields) or raise ModelNotKnownError, name
    end
    
    def find_models(factory, fields = nil)
      factory = pickle_parser.canonical(factory)
      
      models_by_index(factory).clear

      model_class = pickle_config.factories[factory].klass
      conditions  = convert_models_to_attributes(model_class, parse_fields(fields))
      records     = Pickle::Adapter.find_all_models(model_class, conditions)

      records.each {|record| store_model(factory, nil, record)}
    end
    
    # if a column exists in the table which matches the singular factory name, this is used as the pickle ref
    def find_models_from_table(plural_factory, table)
      factory = plural_factory.singularize
      table.hashes.map do |hash|
        pickle_ref = factory + (hash[factory] ? " \"#{hash.delete(factory)}\"" : "")
        find_model(pickle_ref, hash)
      end
    end
    
    # return the original model stored by create_model or find_model
    def created_model(name)
      factory, name_or_index = *parse_model(name)
      
      if name_or_index.blank?
        models_by_index(factory).last
      elsif name_or_index.is_a?(Integer)
        models_by_index(factory)[name_or_index]
      else
        models_by_name(factory)[name_or_index] or raise ModelNotKnownError, name
      end
    end

    # predicate version which raises no errors
    def created_model?(name)
      (created_model(name) rescue nil) ? true : false
    end
    
    # return a newly selected model
    def model(name)
      model = created_model(name)
      return nil unless model
      Pickle::Adapter.get_model(model.class, model.id)
    end
    
    # predicate version which raises no errors
    def model?(name)
      (model(name) rescue nil) ? true : false
    end
    
    # like model, but raise an error if it can't be found
    def model!(name)
      model(name) or raise ModelNotKnownError, name
    end
    
    # like created_model, but raise an error if it can't be found
    def created_model!(name)
      created_model(name) or raise ModelNotKnownError, name
    end
    
    # return all original models of specified type
    def created_models(factory)
      models_by_index(factory)
    end
      
    # return all models of specified type (freshly selected from the database)
    def models(factory)
      created_models(factory).map do |model|
        Pickle::Adapter.get_model(model.class, model.id)
      end
    end
    
    def respond_to_with_pickle_parser?(method, include_private = false)
      respond_to_without_pickle_parser?(method, include_private) || pickle_parser.respond_to?(method, include_private)
    end
    
  protected
    def method_missing_with_pickle_parser(method, *args, &block)
      if pickle_parser.respond_to?(method)
        pickle_parser.send(method, *args, &block)
      else
        method_missing_without_pickle_parser(method, *args, &block)
      end
    end
    
    def pickle_parser=(parser)
      parser.session = self
      @pickle_parser = parser
    end
    
    def pickle_parser
      @pickle_parser or self.pickle_parser = Pickle.parser
    end

    def pickle_config
      pickle_parser.config
    end

    def convert_models_to_attributes(ar_class, attrs)
      attrs.each do |key, val|
        if ((defined?(ActiveRecord::Base) && val.is_a?(ActiveRecord::Base)) ||
          (defined?(DataMapper::Model) && val.is_a?(DataMapper::Model))) &&
          Pickle::Adapter.column_names(ar_class).include?("#{key}_id")
          attrs["#{key}_id"] = val.id
          attrs["#{key}_type"] = val.class.base_class.name if ar_class.column_names.include?("#{key}_type")
          attrs.delete(key)
        end
      end
    end
    
    def models_by_name(factory)
      @models_by_name ||= {}
      @models_by_name[pickle_parser.canonical(factory)] ||= {}
    end
    
    def models_by_index(factory)
      @models_by_index ||= {}
      @models_by_index[pickle_parser.canonical(factory)] ||= []
    end
    
    # if the factory name != the model name, store under both names
    def store_model(factory, name, record)
      store_record(record.class.name, name, record) unless pickle_parser.canonical(factory) == pickle_parser.canonical(record.class.name)
      store_record(factory, name, record)
    end
    
    def store_record(factory, name, record)
      models_by_name(factory)[name] = record
      models_by_index(factory) << record
    end
  end
end
