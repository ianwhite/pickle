Feature: Change capture label
  In order to have it my way
  As a dev
  I want to be able to change the syntax for pickle labels

  Background:
    Given I create an example active_record app
    And I am using orm (active_record) for generating test data
  
  Scenario: parens for labels
    Given I am writing features using pickle, orm (active_record) and the following config:
      """
      Pickle.config.capture_label = /\((.*)\)/
      """
    And a feature "capture_label_with_parens" with:
      """
      Feature: simple
      
        Scenario: simple
          Given there is a user (Fred)
          And there are the following users:
            | user |
            | Jim  |
          Then (Fred)'s name should be the 1st user's name
          And (Jim)'s name should be the 2nd user's name
      """
    Then running the "capture_label_with_parens" feature should pass

  Scenario: curly braces for labels
    Given I am writing features using pickle, orm (active_record) and the following config:
      """
      Pickle.config.capture_label = /\{(.+)\}/
      """
    And a feature "capture_label_with_curly" with:
      """
      Feature: simple

        Scenario: simple
        Given there is a user {Fred}
        And there are the following users:
          | user |
          | Jim  |
        Then {Fred}'s name should be the 1st user's name
        And {Jim}'s name should be the 2nd user's name
      """
    Then running the "capture_label_with_curly" feature should pass

  Scenario: complicated label
    Given I am writing features using pickle, orm (active_record) and the following config:
      """
      Pickle.config.capture_label = /\|label: (.*)\|/
      """
    And a feature "complicated_capture_label" with:
      """
      Feature: simple

        Scenario: simple
        Given there is a user |label: Fred|
        And there are the following users:
          | user |
          | Jim  |
        Then |label: Fred|'s name should be the 1st user's name
        And |label: Jim|'s name should be the 2nd user's name
      """
    Then running the "complicated_capture_label" feature should pass
