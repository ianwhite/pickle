Feature: I can easily create models from my blueprints

  As a plain old AR user
  I want to be able to create models with fields
  So that I can create models quickly and easily in my features
  
  Scenario: I create a user, and see if it looks right
    Given a user exists with name: "Fred"
    Then the user should not have a status

  Scenario: I create a user, and see if it looks right
    Given a user exists with name: "Fred", status: "crayzee"
    Then a user should exist with name: "Fred"
    And a user should exist with status: "crayzee"
    But a user should not exist with name: "Wilma"
  
  Scenario: I create a user via a mapping
    Given I exist with status: "pwned", name: "fred"
    Then I should have a status
    And the user: "me" should have a status
  
  Scenario: I create positive and negative users
    Given a user exists with name: "Fred", attitude_score: +5.42
    And another user exists with name: "Ethel", attitude_score: -1.46
    Then 2 users should exist
    And the 1st user should be a positive person
    And the 2nd user should not be a positive person