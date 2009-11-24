@gen
Feature: allow pickle to generate steps
  In order to get going with pickle
  As a dev
  I want to be able to generate steps

  Scenario: script/generate pickle on fresh cuke install
    Given cucumber has been freshly generated
    When I run "script/generate pickle"
    Then the file features/support/pickle.rb should exist
    And the file features/support/pickle.rb should match /require 'pickle\/world'/
    And the file features/step_definitions/pickle_steps.rb should be identical to the local step_definitions/pickle_steps.rb
    
  Scenario: script/generate pickle path on fresh cuke install
    Given cucumber has been freshly generated
    When I run "script/generate pickle path"
    Then the file features/support/pickle.rb should exist
    And the file features/support/pickle.rb should match /require 'pickle\/world'/
    And the file features/support/pickle.rb should match /require 'pickle\/path\/world'/
    And the file features/step_definitions/pickle_steps.rb should be identical to the local step_definitions/pickle_steps.rb
    And the file features/support/paths.rb should be identical to the local support/paths.rb

  Scenario: script/generate pickle email on fresh cuke install
    Given cucumber has been freshly generated
    When I run "script/generate pickle email"
    Then the file features/support/pickle.rb should exist
    And the file features/support/pickle.rb should match /require 'pickle\/world'/
    And the file features/support/pickle.rb should match /require 'pickle\/email\/world'/
    And the file features/step_definitions/pickle_steps.rb should be identical to the local step_definitions/pickle_steps.rb
    And the file features/step_definitions/email_steps.rb should be identical to the local step_definitions/email_steps.rb
    And the file features/support/email.rb should be identical to the local support/email.rb

  Scenario: script/generate pickle path email on fresh cuke install
    Given cucumber has been freshly generated
    When I run "script/generate pickle path email"
    Then the file features/support/pickle.rb should exist
    And the file features/support/pickle.rb should be identical to the local support/pickle.rb
    And the file features/support/pickle.rb should match /require 'pickle\/world'/
    And the file features/support/pickle.rb should match /require 'pickle\/path\/world'/
    And the file features/support/pickle.rb should match /require 'pickle\/email\/world'/
    And the file features/step_definitions/pickle_steps.rb should be identical to the local step_definitions/pickle_steps.rb
    And the file features/support/paths.rb should be identical to the local support/paths.rb
    And the file features/step_definitions/email_steps.rb should be identical to the local step_definitions/email_steps.rb
    And the file features/support/email.rb should be identical to the local support/email.rb

  Scenario: regenerating pickle
    Given cucumber has been freshly generated
    And pickle path email has been freshly generated
    When I run "script/generate pickle path email"
    Then the file features/support/pickle.rb should match /require 'pickle\/world'/
    And the file features/support/pickle.rb should match /require 'pickle\/path\/world'/
    And the file features/support/pickle.rb should match /require 'pickle\/email\/world'/
    And the file features/step_definitions/pickle_steps.rb should be identical to the local step_definitions/pickle_steps.rb
    And the file features/support/paths.rb should be identical to the local support/paths.rb
    And the file features/step_definitions/email_steps.rb should be identical to the local step_definitions/email_steps.rb
    But the file features/support/pickle.rb should not match /require 'pickle\/world'.*require 'pickle\/world'/
    And the file features/support/pickle.rb should not match /require 'pickle\/path\/world'.*require 'pickle\/path\/world'/
    And the file features/support/pickle.rb should not match /require 'pickle\/email\/world'.*require 'pickle\/email\/world'/
    And the file features/support/email.rb should be identical to the local support/email.rb
