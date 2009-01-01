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
	
	Scenario: I create 7 spoons of various roundness
		Given 3 spoons exist with round: "false"
		And 4 spoons exist with round: "true"
		Then the 1st spoon should not be round
		And the 2nd spoon should not be round
		And the 3rd spoon should not be round
		And the 4th spoon should be round
		And the 5th spoon should be round
		And the 6th spoon should be round
		And the last spoon should be round