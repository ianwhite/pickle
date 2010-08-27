Feature: I can visit a page by named route
  In order to nav in my features
  As a feature writer
  I want to be able visit named routes

  Scenario: visit the new spoons page
    When I go to the new spoon page
    Then I should be at the new spoon page
    And the new spoon page should match route /spoons/new
   