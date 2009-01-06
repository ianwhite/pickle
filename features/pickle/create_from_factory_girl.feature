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
    
		# these use a step created in fork_steps
    Then the first tine should be tine of the fork: "one"
    And the 2nd tine should be tine of fork: "one"
    And the last tine should be tine of the fancy fork

    # the same as above, with the default assoc step defined by pickle_steps
    Then the first tine should be in fork "one"'s tines
		And the 2nd tine should be in fork: "one"'s tines
		And the last tine should be in the fancy fork's tines
    
  Scenario: I create a fork with a tine, and find the tine by the fork
    Given a fork exists
    And a tine exists with fork: the fork
		
		# find a tine using attributes
    Then a tine should exist with fork: the fork

		# assert belongs_to association
		And the fork should be the tine's fork

  Scenario: I create fork via a mapping
    Given killah fork exists
		Then the fork should be fancy
		And the fancy fork: "of cornwood" should be fancy