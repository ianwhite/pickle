module Pickle
  module Page
    # given a array of models, and an optional segment, will attempt to find a matching named route
    def find_path_for(models, segment = nil)
      model_names = models.map{|m| m.class.name.underscore}.join("_")
      unless segment
        return send("#{model_names}_path", *models)
      else
        segment = segment.underscore.gsub(' ','_')
        path = (send("#{model_names}_#{segment}_path", *models) rescue nil) and return path
        path = (send("#{segment}_#{model_names}_path", *models) rescue nil) and return path
        # try splitting up the segment
        if (segments = segment.split('_')).length > 1
          action, segment = segments[0], segments[1..-1].join('_')
          path = (send("#{action}_#{model_names}_#{segment}_path", *models) rescue nil) and return path
        end
      end
      raise "Could not figure out a path for '#{model_names}' and '#{segment}'"
    end
  end
end