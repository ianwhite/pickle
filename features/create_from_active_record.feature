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
  