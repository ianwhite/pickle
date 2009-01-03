# Pickle #

Stick this in vendor/plugins to have cucumber steps that create your models easily from factory-girl or
machinist factories/blueprints.  You can also just use ActiveRecord but it's not as cool.

References to the models are stored, not necessarily for the purpose of checking the db
(although you could use it for that), but for enabling easy reference to urls, and for
building complex givens which require a bunch of models collaborating

## Install ##

Install pickle either as a rails plugin, or a gem

    # plugin
    script/plugin install git://github.com/ianwhite/pickle.git # or add it as a submodule

    # or, gem
    sudo gem install ianwhite-pickle
  
## Get Started ##

(you'd better install cucumber)

    script/generate pickle

Now have a look at `features/step_definitions/pickle_steps.rb`

### Using with plain ole Active Record ###

If you have an AR called 'Post', with required fields 'title', and 'body', then you can now write 
steps like this

    Given a post exists with title: "My Post", body: "My body"

### Using with factory-girl or machinist ###

But you're using Machinist or FactoryGirl right?!  To leverage all of the factories/blueprints
you've written, you can just do stuff like

    Given a user exists
    And another user exists with role: "admin"
  
    # later
    Then a user should exist with name: "Fred"
    And that user should be activated # this uses rspec predicate matchers

#### Machinst: require your blurpints and rest Shams ####

In your `features/support/env.rb` add the following lines at the bottom

    require "#{Rails.root}/spec/blueprints" # or wherever they live
    Before { Sham.rest } # reset Shams in between scenarios

### Referring to models, using models as field values ###

You might want to set up a scenario with several models of the same type.
You can label your models for easy reference.  The following example requires
a post and complaint blueprint (or factory), and requires writing no 
additional steps.

    Given a post: "spam" exists with spam: "true"
    And a post: "sane" exists
    And a complaint exists with complaint_regarding: post "spam"
    And a complaint exists with complaint_regarding: post "sane"

### Configuring Pickle ###

You can tell pickle to use another factory adapter (see Pickle::Adapter), or
create mappings from english expressions to pickle model names.  You can also
override many of the options on the Pickle::Config object if you so choose 

    require 'pickle'
  
    Pickle.configure do |config|
      config.adapters = [:machinist, YourOwnAdapterClass]
      config.map 'me', 'myself', 'my', 'I', :to => 'user: "me"'
    end

## API ##

### Regexps for us in your own steps ###

By default you get three regexps available in the main namespace for use
in creating your own steps: `capture_model`, `capture_fields`, and others (see lib/pickle.rb)

(You can use any of the regexps that Pickle uses by using the Pickle.parser namespace, see
Pickle::Parser::Matchers for the methods available)

#### `capture_model` ####

    Given /^#{capture_model} exists$/ do |model_name|
      model(model_name).should_not == nil
    end

    Then /^I should be at the (.*?) page$/ |page|
      if page =~ /#{capture_model}'s/
        url_for(model($1))
      else
        # ...
      end
    end

    Then /^#{capture_model} should be one of #{capture_model}'s posts$/ do |post, forum|
      model(forum).posts.should include(post)
    end 

#### `capture_fields` ####

This is useful for setting attributes, and knows about pickle model names so that you
can build up composite objects with ease

    Given /^#{capture_model} exists with #{capture_fields}$/ do |model_name, fields|
      create_model(model_name, fields)
    end

    # example of use
    Given a user exists
    And a post exists with author: the user # this step will assign the above user as :author on the post