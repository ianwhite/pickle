Feature: I can easily create models from my blueprints

  As a machinist user
  I want to be able to leverage my blueprints
  So that I can create models quickly and easily in my features
  
  Scenario: I create a spoon, and see if it looks right
    Given a spoon exists
    Then the spoon should be round

  Scenario: I create a non round spoon, and see if it looks right
    Given a spoon exists with round: "false"
    Then the spoon should not be round

  Scenario: I create a named spoon, and see if it has the name
    Given a spoon exists with name: "Pete"
	  Then a spoon should exist with name: "Pete"
	  And the spoon should be round