module Pickle
  module Page
    # given args of pickle model name, and an optional extra action, or segment, will attempt to find
    # a matching named route
    #
    #   find_path_for 'the user', :action => 'edit'       # => /users/3/edit
    #   find_path_for 'the user', 'the comment'           # => /users/3/comments/1
    #   find_path_for 'the user', :segment => 'comments'  # => /users/3/comments
    #
    # If you don;t know if the 'extra' part of the path is an action or a segment, then just
    # pass it as 'extra' and this method will run through the possibilities
    #
    #   find_path_for 'the user', :extra => 'new comment' # => /users/3/comments/new
    def find_path_for(*pickle_names)
      options = pickle_names.extract_options!
      models = pickle_names.map{|m| model(m)}
      if options[:extra]
        path, extra = nil, options[:extra].underscore.gsub(' ','_').split("_")
        (1..extra.length-1).each do |idx|
          break if (path = find_path_for_models_action_segment(models, extra[0..idx-1].join("_"), extra[idx..-1].join("_")))
        end
        path || find_path_for_models_action_segment(models, nil, options[:extra]) || find_path_for_models_action_segment(models, options[:extra], nil)
      else
        find_path_for_models_action_segment(models, options[:action], options[:segment])
      end or raise "Could not figure out a path for #{pickle_names.inspect} #{options.inspect}"
    end
    
  protected
    def find_path_for_models_action_segment(models, action, segment)
      action.nil? || action = action.underscore.gsub(' ','_')
      segment.nil? || segment = segment.underscore.gsub(' ','_')
      model_names = models.map{|m| m.class.name.underscore}.join("_")
      parts = [action, model_names, segment].compact
      send("#{parts.join('_')}_path", *models) rescue nil
    end
  end
end