Feature: I can easily create models with Fabrication

  As a fabrication user
  I want to be able to leverage my fabricators
  So that I can create models quickly and easily in my features

  Scenario: I create a knife, and see if it looks right
    Given a knife exists
    Then the knife should be sharp
    And the knife's sharp should be true

  Scenario: I create a blunt knife, and see if it looks right
    Given a knife exists with sharp: false
    Then the knife should not be sharp

  Scenario: I create a named knife, and see if it has the name
    Given a knife exists with name: "John", sharp: false
    Then a knife should exist with name: "John"
    And the knife should not be sharp

  Scenario: I create 7 knives of various sharpness
    Given 2 knives exist with sharp: false
    And 2 knives exist with sharp: true
    And a knife exists with sharp: false

    Then the 1st knife should not be sharp
    And the 2nd knife should not be sharp
    And the 3rd knife should be sharp
    And the 4th knife should be sharp
    And the 5th knife should not be sharp

    And 3 knives should exist with sharp: false
    And the 1st knife should not be sharp
    And the 2nd knife should not be sharp
    And the last knife should not be sharp

    And 2 knives should exist with sharp: true
    And the first knife should be sharp
    And the last knife should be sharp

  Scenario: ModelNotKnownError should be informative when failing to find
    Given a knife exists with sharp: true
    Then the following should raise a Pickle::Session::ModelNotFoundError with "Can't find a knife with sharp: false from the orm in this scenario":
      """
      Then a knife should exist with sharp: false
      """
