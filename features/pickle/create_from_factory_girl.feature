Feature: I can easily create models from my factories

  As a pickle user
  I want to be able to leverage my factories
  So that I can create models quickly and easily in my features
  
  Scenario: I create a fork, and see if it looks right
    Given a fork exists
    Then the fork should not be completely rusty
    
  Scenario: I create a fork, and see if it looks right
    Given a fork exists with name: "Forky"
    Then a fork should exist with name: "Forky"
    And the fork should not be completely rusty
    
  Scenario: I create some forks, and some tines
    Given a fork: "one" exists
    And a tine exists with fork: fork "one"
    And another tine exists with fork: fork "one"
    
    And a fancy fork exists
    And a tine exists with fork: the fancy fork
    
    Then the first tine should be tine of the fork: "one"
    And the 2nd tine should be tine of fork: "one"
    And the last tine should be tine of the fancy fork

    Then the first tine should be in fork "one"'s tines
    And the 2nd tine should be in fork: "one"'s tines
    And the last tine should be in the fancy fork's tines
    And the fancy fork should be the last tine's fork
    
    But the first tine should not be in the fancy fork's tines
    And the last tine should not be in fork "one"'s tines
    And the fancy fork should not be the first tine's fork
    
  Scenario: I create a fork with a tine, and find the tine by the fork
    Given a fork exists
    And a tine exists with fork: the fork
    
    Then a tine should exist with fork: the fork
  
  Scenario: create a tine with fork refs in a table
    Given 2 forks exist
    And the following tines exist:
      | fork         |
      | the 1st fork |
      | the 2nd fork |
      | the 2nd fork |
    Then the 1st tine should be in the 1st fork's tines
    And the 2nd tine should be in the 2nd fork's tines
		And the 3rd tine should be in the 2nd fork's tines
		And the 1st fork should have 1 tines
		And the 2nd fork should have 2 tines

  Scenario: I create fork via a mapping
    Given killah fork exists
    Then the fork should be fancy
    And the fancy fork: "of cornwood" should be fancy