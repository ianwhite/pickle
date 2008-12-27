Feature: I can easily create models from my blueprints

  As a machinist user
  I want to be able to leverage my blueprints
  So that I can create models quickly and easily in my features
  
  Scenario: I create a spoon, and see if it looks right
    Given a spoon exists
    Then the spoon should be "round"