Feature: I can easily create models from my blueprints

  As a machinist user
  I want to be able to leverage my blueprints
  So that I can create models quickly and easily in my features
  
  Scenario: I create a spoon, and see if it looks right
    Given a spoon exists
    Then the spoon should be round
    And the spoon's round should be true

  Scenario: I create a non round spoon, and see if it looks right
    Given a spoon exists with round: false
    Then the spoon should not be round

  Scenario: I create a named spoon, and see if it has the name
    Given a spoon exists with name: "Pete", round: false
    Then a spoon should exist with name: "Pete"
    And the spoon should not be round
  
  Scenario: I create 7 spoons of various roundness
    Given 2 spoons exist with round: false
    And 2 spoons exist with round: true
    And a spoon exists with round: false
    
    Then the 1st spoon should not be round
    And the 2nd spoon should not be round
    And the 3rd spoon should be round
    And the 4th spoon should be round
    And the 5th spoon should not be round
    
    And 3 spoons should exist with round: false
    And the 1st spoon should not be round
    And the 2nd spoon should not be round
    And the last spoon should not be round
    
    And 2 spoons should exist with round: true
    And the first spoon should be round
    And the last spoon should be round