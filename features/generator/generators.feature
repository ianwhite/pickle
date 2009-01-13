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
    And the file features/support/env.rb should match /require 'pickle'/
    
  More Examples:
    | WHEN I RUN                  | THE FILE SHOULD EXIST                           | AND THE FILE            | SHOULD MATCH                  |
    | script/generate pickle      | features/step_definitions/pickle_steps.rb       | features/support/env.rb | Example of configuring pickle:|
    | script/generate pickle page | features/step_definitions/pickle_page_steps.rb  | features/support/env.rb | require 'pickle_page'         |
    | script/generate pickle email| features/step_definitions/pickle_email_steps.rb | features/support/env.rb | require 'pickle_email'        |
    
  Scenario: script/generate pickle, when env.rb has already requires pickle
    Given cucumber has been freshly generated
    And env.rb already requires pickle
    When I run "script/generate pickle"
    Then the file features/support/env.rb should not match /Example of configuring pickle:/
  
  More Examples:
    | ENV.RB REQUIRES | WHEN I RUN                    | THE FILE                | SHOULD NOT MATCH                              |
    | pickle          | script/generate pickle        | features/support/env.rb | require 'pickle'.*require 'pickle'            |
    | pickle_page     | script/generate pickle page   | features/support/env.rb | require 'pickle_path'.*require 'pickle_path'  |
    | pickle_email    | script/generate pickle email  | features/support/env.rb | require 'pickle_email'.*require 'pickle_email'|
    
  Scenario: script/generate pickle page email
    Given cucumber has been freshly generated
    When I run "script/generate pickle page email"
    Then the file features/step_definitions/pickle_email_steps.rb should exist
    And the file features/step_definitions/pickle_page_steps.rb should exist
    And the file features/step_definitions/pickle_steps.rb should exist
    And the file features/support/env.rb should match /require 'pickle'/
    And the file features/support/env.rb should match /require 'pickle_page'/
    And the file features/support/env.rb should match /require 'pickle_email'/




  
