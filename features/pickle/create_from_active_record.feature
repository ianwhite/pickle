Feature: I can easily create models from my blueprints

  As a plain old AR user
  I want to be able to create models with fields
  So that I can create models quickly and easily in my features
  
  @wip
  Scenario: I create a user, and see if it looks right
    Given a user exists with name: "Fred", has_stale_password: true
    Then the user should not have a status
    And the user should have a stale password
    And the user's name should be "Fred"
    
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
    And another user exists with name: "Ethel", attitude_score: -10
		And another user exists with name: "Buddha", attitude_score: 2_000_000
    Then 3 users should exist
    And the 1st user should be a positive person
    And the 2nd user should not be a positive person
    And the 1st user's attitude_score should be 5.42
    And the 2nd user's attitude_score should be -10
		And the 3rd user's attitude_score should be 2_000_000
  	And the 3rd user's attitude_score should be 2000000

  Scenario: I create nil values
    Given a user exists with name: "Fred", attitude_score: nil
    Then 1 users should exist with attitude_score: nil
    And that user should be the first user
    And that user should have no attitude
    And that user's attitude_score should be nil
    
  Scenario: create and find using tables
    Given the following users exist:
      | name  | status                   |
      | Jim   | married                  |
      | Ethel | in a relationship with x |
    Then the following users should exist:
      | name  |
      | Jim   |
      | Ethel |
    And the following users should exist:
      | status                   |
      | married                  |
      | in a relationship with x |
    And the 1st user should be the 3rd user
    And the 2nd user should be the last user
    
    Scenario: create and find using tables with referencable names
      Given the following users exist:
        | user | name | status |
        | Jack | Jack | alone  |
        | Pete | Pete | dead   |
      Then the following users should exist:
        | name |
        | Jack |
        | Pete |
      And the following users should exist:
        | user    | status |
        | lonely  | alone  |
        | rotting | dead   |
      And the 1st user should be the user: "Jack"
      And the 2nd user should be the user: "Pete"
      And the user: "lonely" should be the user: "Jack"
      And the user: "rotting" should be the user: "Pete"
