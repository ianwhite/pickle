Feature: Change capture label
  In order to have it my way
  As a dev
  I want to be able to change the syntax for pickle labels

  Background:
    Given an example active_record/orm app
  
  Scenario: parens for labels
    Given a pickle config:
      """
      Pickle.config.capture_label = /\((.*)\)/
      """
    
    Then the following steps should pass:
      """
      Given a user (Fred)
      And the following users:
        | user |
        | Jim  |
      Then (Fred)'s name should be the 1st user's name
      And (Jim)'s name should be the 2nd user's name
      """

  Scenario: angle brackets braces for labels
    Given a pickle config:
      """
      Pickle.config.capture_label = /<([^<>]+)>/
      """
    Then the following steps should pass:
      """
      Given a user <Fred>
      And the following users:
        | user |
        | Jim  |
      Then <Fred>'s name should be the 1st user's name
      And <Jim>'s name should be the 2nd user's name
      """

  Scenario: complicated label
    Given a pickle config:
      """
      Pickle.config.capture_label = /\|pickle: (.*)\|/
      """
    
    Then the following steps should pass:
      """
      Given a user |pickle: Fred|
      And the following users:
        | user |
        | Jim  |
      Then |pickle: Fred|'s name should be the 1st user's name
      And |pickle: Jim|'s name should be the 2nd user's name
      """
