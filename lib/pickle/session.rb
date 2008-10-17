module Pickle
  class Session
    include Parser
    
    def create_model(a_model_name, fields = nil)
      factory, name = *parse_model(a_model_name)
      raise ArgumentError, "Can't create a model with an ordinal (e.g. 1st user)" if name.is_a?(Integer)
      record = Factory(factory, parse_fields(fields))
      store_model(factory, name, record)
    end

    def find_model(a_model_name, fields)
      model, name = *parse_model(a_model_name)
      if record = model.classify.constantize.find(:first, :conditions => convert_models_to_ids(parse_fields(fields)))
        store_model(model, name, record)
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find #{model} with #{fields}"
      end
    end
    
    # return the original model stored by create_model or find_model
    def original_model(a_model_name)
      factory, name_or_index = *parse_model(a_model_name)
      
      if name_or_index.blank?
        models_by_factory(factory).last
      elsif name_or_index.is_a?(Integer)
        models_by_factory(factory)[name_or_index]
      else
        models_by_name(factory)[name_or_index] or raise "model: #{a_model_name} does not refer to known model in this scenario"
      end
    end

    # predicate version which raises no errors
    def original_model?(a_model_name)
      (original_model(a_model_name) rescue nil) ? true : false
    end
    
    # return a newly selected model
    def model(a_model_name)
      if model = original_model(a_model_name)
        model.class.find(model.id) or raise ActiveRecord::RecordNotFound, "model: #{a_model_name} could not be found in the database"
      end
    end
    
    # predicate version which raises no errors
    def model?(a_model_name)
      (model(a_model_name) rescue nil) ? true : false
    end
    
    # return all original models of specified type
    def original_models(factory)
      models_by_factory(factory)
    end
      
    # return all models of specified type (freshly selected from the database)
    def models(factory)
      original_models(factory).map do |model|
        model.class.find(model.id)
      end
    end
    
    def parse_field_with_model(field)
      if field =~ /^(\w+): (#{Match::Model})$/
        {$1 => model($2)}
      else
        parse_field_without_model(field)
      end
    end
    alias_method_chain :parse_field, :model

  private
    def convert_models_to_ids(attrs)
      attrs.each do |key, val|
        if val.is_a?(ActiveRecord::Base)
          attrs["#{key}_id"] = val.id
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
      store_record(canonical(record.class.name), name, record) if canonical(record.class.name) != factory
      store_record(factory, name, record)
    end

    def store_record(factory, name, record)
      models_by_name(factory)[name] = record
      models_by_factory(factory) << record
    end
  end
end