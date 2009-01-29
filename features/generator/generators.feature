Feature: allow pickle to generate steps
  In order to get going with pickle
  As a dev
  I want to be able to generate steps

  Scenario: cucumber is not yet installed
    When I run "script/generate pickle"
    Then I should see "try running script/generate cucumber"
    
  Scenario Outline: script/generate pickle on fresh cuc install
    Given cucumber has been freshly generated
    When I run "<GENERATE PICKLE>"
    Then the file <STEPS FILE> should exist
    And the file features/support/env.rb should match /<ENV.RB SHOULD MATCH>/
    
  Examples:
    | GENERATE PICKLE             | STEPS FILE                                | ENV.RB SHOULD MATCH             |
    | script/generate pickle      | features/step_definitions/pickle_steps.rb | require 'pickle\/world'         |
    | script/generate pickle      | features/step_definitions/pickle_steps.rb | Example of configuring pickle:  |
    | script/generate pickle email| features/step_definitions/email_steps.rb  | require 'pickle\/email\/world'  |
    
  Scenario: script/generate pickle path on fresh cuc install
    Given cucumber has been freshly generated
    When I run "script/generate pickle path"
    Then the file features/support/env.rb should match /require 'pickle\/world'/
    And the file features/support/paths.rb should match /added by script/generate pickle path/
    And the file features/support/paths.rb should be identical to the local support/paths.rb

  Scenario Outline: script/generate pickle, when env.rb has already requires pickle
    Given cucumber has been freshly generated
    And env.rb already requires <ENV.RB CONTAINS>
    When I run "<GENERATE PICKLE>"
    Then the file features/support/env.rb should not match /<ENV.RB SHOULD NOT MATCH>/
  
  Examples:
    | ENV.RB CONTAINS   | GENERATE PICKLE               | ENV.RB SHOULD NOT MATCH                                       |
    | pickle/world      | script/generate pickle        | Example of configuring pickle:                                |
    | pickle/world      | script/generate pickle        | require 'pickle\/world'.*require 'pickle\/world'              |
    | pickle/path/world | script/generate pickle path   | require 'pickle\/path\/world'.*require 'pickle\/path\/world'  |
    | pickle/email/world| script/generate pickle email  | require 'pickle\/email\/world'.*require 'pickle\/email\/world'|
    
  Scenario: script/generate pickle page email
    Given cucumber has been freshly generated
    When I run "script/generate pickle path email"
    Then the file features/step_definitions/email_steps.rb should exist
    And the file features/step_definitions/pickle_steps.rb should exist
    And the file features/support/env.rb should match /require 'pickle\/world'/
    And the file features/support/env.rb should match /require 'pickle\/path\/world'/
    And the file features/support/env.rb should match /require 'pickle\/email\/world'/
    And the file features/support/paths.rb should match /added by script/generate pickle path/



  
