Feature: allow pickle to generate steps
  In order to get going with pickle
  As a dev
  I want to be able to generate steps

  Scenario: cucumber is not yet installed
    When I run "script/generate pickle"
    Then I should see "try running script/generate cucumber"
    
  Scenario: script/generate pickle on fresh cuc install
    Given cucumber has been freshly generated
    When I run "script/generate pickle"
    Then the file features/step_definitions/pickle_steps.rb should exist
    And the file features/support/env.rb should match /require 'pickle\/world'/
    
  More Examples:
    | WHEN I RUN                  | THE FILE SHOULD EXIST                     | AND THE FILE            | SHOULD MATCH                  |
    | script/generate pickle      | features/step_definitions/pickle_steps.rb | features/support/env.rb | Example of configuring pickle:|
    | script/generate pickle email| features/step_definitions/email_steps.rb  | features/support/env.rb | require 'pickle\/email\/world'|
    
  Scenario: script/generate pickle path on fresh cuc install
    Given cucumber has been freshly generated
    When I run "script/generate pickle path"
    Then the file features/support/env.rb should match /require 'pickle\/world'/
    And the file features/support/paths.rb should match /added by script/generate pickle path/

  Scenario: script/generate pickle, when env.rb has already requires pickle
    Given cucumber has been freshly generated
    And env.rb already requires pickle/world
    When I run "script/generate pickle"
    Then the file features/support/env.rb should not match /Example of configuring pickle:/
  
  More Examples:
    | ENV.RB REQUIRES   | WHEN I RUN                    | THE FILE                | SHOULD NOT MATCH                                      |
    | pickle/world      | script/generate pickle        | features/support/env.rb | require 'pickle\/world'.*require 'pickle\/world'              |
    | pickle/path/world | script/generate pickle path   | features/support/env.rb | require 'pickle\/path\/world'.*require 'pickle\/path\/world'  |
    | pickle/email/world| script/generate pickle email  | features/support/env.rb | require 'pickle\/email\/world'.*require 'pickle\/email\/world'|
    
  Scenario: script/generate pickle page email
    Given cucumber has been freshly generated
    When I run "script/generate pickle path email"
    Then the file features/step_definitions/email_steps.rb should exist
    And the file features/step_definitions/pickle_steps.rb should exist
    And the file features/support/env.rb should match /require 'pickle\/world'/
    And the file features/support/env.rb should match /require 'pickle\/path\/world'/
    And the file features/support/env.rb should match /require 'pickle\/email\/world'/
    And the file features/support/paths.rb should match /added by script/generate pickle path/



  
