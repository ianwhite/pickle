Given "I am using orm for generating test data" do
  create_file "lib/factory.rb", '# nothing to do for orm as factory adapter'
end

Given "I am using factory_girl for generating test data" do
  create_file "lib/factory.rb", <<-FILE
    require 'factory_girl'
    
    Factory.define :user do |u|
      u.name "made by factory_girl"
    end

    Factory.define :note do |n|
      n.body "made by factory_girl"
    end
  FILE
end

Given "I am using machinist for generating test data" do
  create_file "lib/factory.rb", <<-FILE
    if defined?(DataMapper)
      require 'machinist/data_mapper'
    else
      require 'machinist/active_record'
    end

    User.blueprint do
      name "made by machinist"
    end

    Note.blueprint do
      body "made by machinist"
    end
  FILE
end