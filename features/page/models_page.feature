Feature: I can visit a page for a model
  In order to easily go to pages for models I've created
  As a feature writer
  I want to be able visit pages their model

  Scenario: create a spoon, go its page
    Given a spoon exists
    When I go to the spoon's page
    Then I should be at the spoon's page
    
  Scenario: create a couple of spoon, go to some pages
    Given a spoon: "fred" exists
    And a spoon: "ethel" exists
    
    When I go to spoon: "fred"'s edit page
    Then I should be at the 1st spoon's edit page
    
    When I go to the spoon "ethel"'s page
    Then I should be at the 2nd spoon's page