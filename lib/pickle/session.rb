module Pickle
  class Session
    def initialize(options = {})
      self.parser = options[:parser] || Pickle.parser
      @config = parser.config
    end

    def create_model(a_model_name, fields = nil)
      factory, label = *parser.parse_model(a_model_name)
      raise ArgumentError, "Can't create with an ordinal (e.g. 1st user)" if label.is_a?(Integer)
      record = config.factories[factory].create(parser.parse_fields(fields))
      store_model(factory, label, record)
    end

    def find_model(a_model_name, fields = nil)
      factory, name = *parser.parse_model(a_model_name)
      raise ArgumentError, "Can't find a model with an ordinal (e.g. 1st user)" if name.is_a?(Integer)
      model_class = config.factories[factory].klass
      if record = model_class.find(:first, :conditions => convert_models_to_attributes(model_class, parser.parse_fields(fields)))
        store_model(factory, name, record)
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find #{model}#{" with #{fields}" if fields}"
      end
    end
    
    def find_models(factory, fields = nil)
      model_class = config.factories[factory].klass
      if records = model_class.find(:all, :conditions => convert_models_to_attributes(model_class, parser.parse_fields(fields)))
        records.each {|record| store_model(factory, nil, record)}
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find any #{factory_name.pluralize}#{" with #{fields}" if fields}"
      end
    end
    
    def clear_models(factory)
      models_by_name(factory).clear
      models_by_factory(factory).clear
    end
      
    # return the original model stored by create_model or find_model
    def created_model(name)
      factory, name_or_index = *parser.parse_model(name)
      
      if name_or_index.blank?
        models_by_factory(factory).last
      elsif name_or_index.is_a?(Integer)
        models_by_factory(factory)[name_or_index]
      else
        models_by_name(factory)[name_or_index] or raise "model: #{name} does not refer to known model in this scenario"
      end
    end

    # predicate version which raises no errors
    def created_model?(name)
      (created_model(name) rescue nil) ? true : false
    end
    
    # return a newly selected model
    def model(name)
      (model = created_model(name)) && model.class.find(model.id)
    end
    
    # predicate version which raises no errors
    def model?(name)
      (model(name) rescue nil) ? true : false
    end
    
    # return all original models of specified type
    def created_models(factory)
      models_by_factory(factory)
    end
      
    # return all models of specified type (freshly selected from the database)
    def models(factory)
      created_models(factory).map{|model| model.class.find(model.id) }
    end
    
  protected
    attr_reader :parser, :config
  
    def parser=(parser)
      parser.session = self
      @parser = parser
    end
    
    def convert_models_to_attributes(ar_class, attrs)
      attrs.each do |key, val|
        if val.is_a?(ActiveRecord::Base) && ar_class.column_names.include?("#{key}_id")
          attrs["#{key}_id"] = val.id
          attrs["#{key}_type"] = val.class.name if ar_class.column_names.include?("#{key}_type")
          attrs.delete(key)
        end
      end
    end
    
    def models_by_name(factory)
      @models_by_name ||= {}
      @models_by_name[factory] ||= {}
    end
    
    def models_by_factory(factory)
      @models_by_factory ||= {}
      @models_by_factory[factory] ||= []
    end
    
    # if the factory name != the model name, store under both names
    def store_model(factory, name, record)
      store_record(parser.canonical(record.class.name), name, record) if parser.canonical(record.class.name) != factory
      store_record(factory, name, record)
    end

    def store_record(factory, name, record)
      models_by_name(factory)[name] = record
      models_by_factory(factory) << record
    end
  end
end