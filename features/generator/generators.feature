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
    And the file features/support/env.rb should contain "require 'pickle'"
    And the file features/support/env.rb should contain "Example of configuring pickle:"
    
  Scenario: script/generate pickle, when env.rb has already requires pickle
    Given cucumber has been freshly generated
    And env.rb already requires pickle
    When I run "script/generate pickle"
    Then the file features/support/env.rb should not contain "Example of configuring pickle:"
    
  Scenario: script/generate pickle page
    Given cucumber has been freshly generated
    When I run "script/generate pickle page"
    Then the file features/step_definitions/page_steps.rb should exist
    And the file features/step_definitions/pickle_steps.rb should exist
    
    
  
  
