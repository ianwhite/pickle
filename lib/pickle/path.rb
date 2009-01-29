module Pickle
  module Path
    # given args of pickle model name, and an optional extra action, or segment, will attempt to find
    # a matching named route
    #
    #   path_to_pickle 'the user', :action => 'edit'       # => /users/3/edit
    #   path_to_pickle 'the user', 'the comment'           # => /users/3/comments/1
    #   path_to_pickle 'the user', :segment => 'comments'  # => /users/3/comments
    #
    # If you don;t know if the 'extra' part of the path is an action or a segment, then just
    # pass it as 'extra' and this method will run through the possibilities
    #
    #   path_to_pickle 'the user', :extra => 'new comment' # => /users/3/comments/new
    def path_to_pickle(*pickle_names)
      options = pickle_names.extract_options!
      models = pickle_names.map{|m| model(m)}
      if options[:extra]
        parts = options[:extra].underscore.gsub(' ','_').split("_")
        find_pickle_path_using_action_segment_combinations(models, parts)
      else
        pickle_path_for_models_action_segment(models, options[:action], options[:segment])
      end or raise "Could not figure out a path for #{pickle_names.inspect} #{options.inspect}"
    end
    
  protected
    def find_pickle_path_using_action_segment_combinations(models, parts)
      path = nil
      (0..parts.length).each do |idx|
        action  = parts.slice(0, idx).join('_')
        segment = parts.slice(idx, parts.length).join('_')
        path = pickle_path_for_models_action_segment(models, action, segment) and break
      end
      path
    end
    
    def pickle_path_for_models_action_segment(models, action, segment)
      action.blank? or action = action.downcase.gsub(' ','_')
      segment.blank? or segment = segment.downcase.gsub(' ','_')
      model_names = models.map{|m| m.class.name.underscore}.join("_")
      parts = [action, model_names, segment].reject(&:blank?)
      send("#{parts.join('_')}_path", *models) rescue nil
    end
  end
end