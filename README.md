# pickle

[<img src="https://travis-ci.org/ianwhite/pickle.svg" alt="Build Status"
/>](https://travis-ci.org/ianwhite/pickle)

Pickle gives you cucumber steps that create your models easily from
factory-girl, machinist, or fabrication.  You can also just use ActiveRecord as
a factory but it's not as cool.

Pickle can make use of different ORMs for finding records.  Currently
ActiveRecord, DataMapper, MongoID adapters are provided.  More adapters
welcome!

References to the models are stored in the current world, not necessarily for
the purpose of checking the db (although you could use it for that), but for
enabling easy reference to urls, and for building complex givens which require
a bunch of models collaborating

## Quickstart

This is a quickstart guide for rails apps.  Firstly, install
[cucumber-rails](http://github.com/aslakhellesoy/cucumber-rails), and its
dependencies. Then do the following:

### Rails 3:

Add the gem to your Gemfile:

```ruby
gem 'pickle'
```

Then install with:

```shell
bundle install
```

Discover the options for the generator:

```shell
rails g pickle --help
```

Run the generator, e.g:

```shell
rails g pickle --paths --email
```

### For Rails 2:

Add the following to config/environments/cucumber:

```ruby
config.gem 'pickle'
```

Install the gem with

```shell
rake gems:install RAILS_ENV=cucumber
```

Run the generator with:

```ruby
script/generate pickle [paths] [email]
```

## Resources

**GitHub** for code: https://github.com/ianwhite/pickle

**RubyGems** for the gem: https://rubygems.org/gems/pickle

**RubyDoc.info** for docs: http://www.rubydoc.info/github/ianwhite/pickle

**Google Group** for questions:
https://groups.google.com/group/pickle-cucumber

**Railscast** presentation:
http://railscasts.com/episodes/186-pickle-with-cucumber

**Blog articles**: [rubyflare: pickle my
cucumber](http://rubyflare.com/2009/10/28/pickle-my-cucumber/)

## Using Pickle

Now have a look at `features/step_definitions/pickle_steps.rb`

If you want path steps and email steps then just add the 'paths' and/or
'email' options to the generator. The code/steps will be written to
`features/env/paths.rb` and `features/step_definitions/email_steps.rb`
respectively.

### Using with plain ole Active Record, DataMapper or Mongoid

Pickle comes with ORM adapters for Active Record, DataMapper and Mongoid.

If you have a model called 'Post', with required fields 'title', and 'body',
then you can now write steps like this

```gherkin
Given a post exists with title: "My Post", body: "My body"
```

### Using with factory-girl or machinist

But you're using Machinist or FactoryGirl right?!  To leverage all of the
factories/blueprints you've written, you can just do stuff like

```gherkin
Given a user exists
And another user exists with role: "admin"

# later
Then a user should exist with name: "Fred"
And that user should be activated # this uses rspec predicate matchers
```

#### Machinist: require your blueprints

In your `features/support/env.rb` add the following lines at the bottom

```ruby
require "#{Rails.root}/spec/blueprints" # or wherever they live
```

#### FactoryGirl: make sure factories are loaded

In your config/environments/cucumber.rb file, make sure the factory-girl gem
is included (unless it's installed as a plugin).

If that doesn't solve loading issues then require your factories.rb file
directly in a file called 'features/support/factory_girl.rb'

```ruby
# example features/support/factory_girl.rb
require File.dirname(__FILE__) + '/../../spec/factories'
```

### Using with an ORM other than ActiveRecord, DataMapper, or Mongoid

Pickle can be used with any modelling library provided there is an adapter
written for it.

Adapters are very simple and exist a module or class with the name
"PickleAdapter" available to the class.  For example

```ruby
User.const_get(:PickleAdapter) #=> should return a pickle adapter
```

The Active Record and DataMapper ones can be found at
ActiveRecord::Base::PickleAdapter, DataMapper::Resource::PickleAdapter,
Mongoid::Document::PickleAdapter respectively.

See how to implement one by looking at the ones provided in the pickle source
in lib/pickle/adapters/\*

### Configuring Pickle

You can tell pickle to use another factory adapter (see Pickle::Adapter), or
create mappings from english expressions to pickle model names.  You can also
override many of the options on the Pickle::Config object if you so choose.

In: `features/support/pickle.rb`

```ruby
require 'pickle/world'

Pickle.configure do |config|
  config.adapters = [:machinist, :active_record, YourOwnAdapterClass]
  config.map 'me', 'myself', 'my', 'I', :to => 'user: "me"'
end
```

Out of the box pickle looks for machinist, factory-girl, then uses the ORM(s)
that you're using to create models.

If you find that your steps aren't working with your factories, it's probably
the case that your factory setup is not being included in your cucumber
environment (see comments above regarding machinist and factory-girl).

## API

### Steps

When you run `script/generate pickle` you get the following steps

#### Given steps

"Given **a model** exists",  e.g.

```gherkin
Given a user exists
Given a user: "fred" exists
Given the user exists
```

"Given **a model** exists with **fields**",  e.g.

```gherkin
Given a user exists with name: "Fred"
Given a user exists with name: "Fred", activated: false
```

This last step could be better expressed by using Machinist/FactoryGirl to
create an activated user.  Then you can do

```gherkin
Given an activated user exists with name: "Fred"
```

You can refer to other models in the fields

```gherkin
Given a user exists
And a post exists with author: the user

Given a person "fred" exists
And a person "ethel" exists
And a fatherhood exists with parent: person "fred", child: person "ethel"
```

This last step is given by the default pickle steps, but it would be better
written as:

```gherkin
And "fred" is the father of "ethel"
```

It is expected that you'll need to expand upon the default pickle steps to
make your features readable.  To write the  above step, you could do something
like:

```ruby
Given /^"(\w+)" is the father of "(\w+)"$/ do |father, child|
  Fatherhood.create! :father => model!("person: \"#{father}\""), :child => model!("person: \"#{child}\"")
end 
```

"Given **n models** exist", e.g.

```gherkin
Given 10 users exist
```

"Given **n models** exist with **fields**", examples:

```gherkin
Given 10 users exist with activated: false
```

"Given the following **models** exist:", examples:

```gherkin
Given the following users exist
  | name  | activated |
  | Fred  | false     |
  | Ethel | true      |
```

##### Named machinist blueprints

"Given **a _named_ model** exists with **fields**"

The latest version of pickle supports [named machinist
blueprints](http://github.com/notahat/machinist/commit/d6492e6927a8aa1819926e4
8b22377171fd20496).

If you had the following blueprints:

```ruby
User.blueprint do
  name
  email
end

User.blueprint(:super_admin) do
  role { "admin" }
end

User.blueprint(:activated) do
  activated { true }
end
```

You could create a user with pickle by simply adding the name of the blueprint
before the model:

```gherkin
Given a super admin user exists
And an activated user exists with name: "Fred"
```

This is much nicer than having to set up common configurations in your steps
all the time, and far more readable to boot.

#### Then steps

##### Asserting existence of models

"Then **a model** should exist",  e.g.

```gherkin
Then a user should exist
```

"Then **a model** should exist with **fields**", e.g.

```gherkin
Then a user: "fred" should exist with name: "Fred" # we can label the found user for later use
```

You can use other models, booleans, numerics, and strings as fields

```gherkin
Then a person should exist with child: person "ethel"
Then a user should exist with activated: false
Then a user should exist with activated: true, email: "fred@gmail.com"
```

"Then **n models** should exist", e.g.

```gherkin
Then 10 events should exist
```

"Then **n models** should exist with **fields**", e.g.

```gherkin
Then 2 people should exist with father: person "fred"
```

"Then the following **models** exist". This allows the creation of multiple
models using a table syntax. Using a column with the singularized name of the
model creates a referenceable model. E.g.

```gherkin
Then the following users exist:
  | name   | activated |
  | Freddy | false     |

Then the following users exist:
  | user | name   | activated |
  | Fred | Freddy | false     |
```

##### Asserting associations

One-to-one assocs: "Then **a model** should be **other model**'s
**association**", e.g.

```gherkin
Then the person: "fred" should be person: "ethel"'s father
```

Many-to-one assocs: "Then **a model** should be [in|one of] **other model**'s
**association**", e.g.

```gherkin
Then the person: "ethel" should be one of person: "fred"'s children
Then the comment should be in the post's comments
```

##### Asserting predicate methods

"Then **a model** should [be|have] [a|an] **predicate**", e.g.

```gherkin
Then the user should have a status # => user.status.should be_present
Then the user should have a stale password # => user.should have_stale_password
Then the car: "batmobile" should be fast # => car.should be_fast
```

"Then **a model** should not [be|have] [a|an] **predicate**", e.g.

```gherkin
Then person: "fred" should not be childless # => fred.should_not be_childless
```

### Regexps for use in your own steps

By default you get some regexps available in the main namespace for use in
creating your own steps: `capture_model`, `capture_fields`, and others (see
lib/pickle.rb)

(You can use any of the regexps that Pickle uses by using the Pickle.parser
namespace, see Pickle::Parser::Matchers for the methods available)

**capture_model**

```ruby
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
  post = model!(post)
  forum = model!(forum)
  forum.posts.should include(post)
end
```

**capture_fields**

This is useful for setting attributes, and knows about pickle model names so
that you can build up composite objects with ease

```ruby
Given /^#{capture_model} exists with #{capture_fields}$/ do |model_name, fields|
  create_model(model_name, fields)
end

# example of use
Given a user exists
And a post exists with author: the user # this step will assign the above user as :author on the post
```

### Email Steps

When you run `rails g pickle --email` you get steps for handling email.

The general pattern of use is to clear the email queue (if necessary), have
your app perform something that sends emails, assert that emails have been
delivered, then assert  those emails have particular properties.

For example:

```gherkin
Background:
  Given a user has signed up
  And all emails have been delivered
  And the user has signed in

Scenario: User buys a fork
  Given I am on the fork page
  And I press "Buy Fork!"
  Then 1 email should be delivered to the user
  And the email should contain "You can haz Fork!"
  When I follow the "my account" link in the email
  Then I should be on the account page

  And 1 email should be delivered to "sales@example.com"
  And the email should contain the user's page
  And the email should contain "User can haz Fork!"
```

You can refer to emails that were found in the `Then *n* emails should be
delivered` in the following ways:

```gherkin
the email (refers to last email)
the 1st email
the last email
email to: "joe@example.com"
email subject: "some subject"
email to: "joe@example.com", subject: "some subject"
```

#### Map expressions to email addresses

By default a step like

```gherkin
Then 2 emails should be delivered to the user "Ethel"
```

Will look for the `email` attribute on the found model.  This is configurable
in much the same way as page names for url paths.  Have a look at
`features/support/email.rb` to add your own custom mappings.

For example:

```ruby
# in features/support/email.rb
when /^#{capture_model} sales team$/
  model!($1).sales_email

# in a feature
  Given a site exists
  And someone buys something form the site
  Then 1 email should be delivered to the site sales team
```

More detail on the emails steps follows:

#### Given steps

Clear the email queue, e.g.

```gherkin
Given all email has been delivered
Given all emails have been delivered
```

#### When steps

When **[I|they]** follow **[text_or_regex|the first link]** the email, e.g.

```gherkin
When I click the first link in the email
When I follow "http://example.com/pickle" in the email
When I follow "some link text" in the email
```

#### Then steps

Then **n** email(s) should be delivered to **address**, e.g.

```gherkin
Then 1 email should be delivered to joe@example.com
```

Then **n** email(s) should be delivered with **fields**, e.g.

```gherkin
Then 2 emails should be delivered with subject: "Welcome to pickle"
Then 2 email should be delivered with to: "joe@example.com", from: "pickle@example.com"
```

Then **fields** should be delivered to **address**, e.g.

```gherkin
Then subject: "Welcome to pickle" should be delivered to joe@example.com
```

Then **fields** should be not delivered to **address**, e.g.

```gherkin
Then subject: "Welcome to pickle" should not be delivered to pickle@example.com
```

Then **email** should have **fields**, e.g.

```gherkin
Then the email should have subject: "Welcome to pickle", from: "pickle@example.com"
```

Then **email** should contain "**text**", e.g.

```gherkin
Then the email should contain "Thank you for choosing pickle"
```

Then **email** should not contain "**text**", e.g.

```gherkin
Then the email should not contain "v1@gr@"
```

Then **email** should link to "**href**", e.g.

```gherkin
Then the email should link to http://example.com/pickle
```

Then show me the email(s), will open the email(s) in your browser (depends on
OS X)

```gherkin
Then show me the email(s)
```

## Run the tests

To run the specs and features, you can start from the last known good set of
gem dependencies in Gemfile.lock.development:

```ruby
git clone http://github.com/ianwhite/pickle
cd pickle
cp Gemfile.lock.development Gemfile.lock
bundle
```

To run the specs & features do:

```ruby
bundle exec rake spec
bundle exec rake cucumber
```

## Contributors

The following people have made Pickle better:

*   [Jules Copeland](http://github.com/julescopeland)
*   [David Padilla](http://github.com/dabit)
*   [Ari Epstein](http://github.com/aepstein)
*   [Jonathan Hinkle](http://github.com/hynkle)
*   [Devin Walters and Nick Karpenske](http://github.com/bendyworks)
*   [Marc Lee](http://github.com/maleko)
*   [Sebastian Zuchmanski](http://github.com/sebcioz)
*   [Paul Gideon Dann](http://github.com/giddie)
*   [Tom Meier](http://github.com/tommeier)
*   [Sean Hussey](http://github.com/seanhussey)
*   Brian Rose & Kevin Olsen
*   [Christopher Darroch](http://github.com/chrisdarroch)
*   [Szymon Nowak](http://github.com/szimek)
*   [H.J. Blok](http://github.com/hjblok)
*   [Daniel Neighman](http://github.com/hassox)
*   [Josh Bassett](http://github.com/nullobject)
*   [Nick Rutherford](http://github.com/nruth)
*   [Tobi Knaup](http://github.com/guenter)
*   [Michael MacDonald](http://github.com/schlick)
*   [Michael Moen](http://github.com/UnderpantsGnome)
*   [Myron Marston](http://github.com/myronmarston)
*   [Stephan Hagemann](http://github.com/xing)
*   [Chris Flipse](http://github.com/cflipse)
*   [Jon Kinney](http://github.com/jondkinney)
