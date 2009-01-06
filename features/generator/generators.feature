Feature: allow pickle to generate steps
  In order to get going with pickle
  As a dev
  I want to be able to generate steps

  Scenario: cucumber is not yet installed
    Given cucumber has not been generated
    When I run "script/generate pickle"
    Then I should see "try running script/generate cucumber"
    
  Scenario: cucumber has been installed
    Given cucumber has been generated
    When I run "script/generate pickle"
    Then the file features/step_definitions/pickle_steps.rb should exist
    And the file features/support/env.rb should contain "require 'pickle'"
    And the file features/support/env.rb should contain "Example of configuring pickle:"
    
  Scenario: env.rb has already been modified to require pickle
    Given cucumber has been generated
    And env.rb already requires pickle
    When I run "script/generate pickle"
    Then the file features/support/env.rb should not contain "Example of configuring pickle:"
    
    
  
  
