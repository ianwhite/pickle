Feature: I can visit a page for a model
  In order to easily go to pages for models I've created
  As a feature writer
  I want to be able visit pages their model

  Scenario: create a spoon, go its page
    Given a spoon exists
    When I go to the spoon's page
    Then I should be at the spoon's page
    And the spoon's page should match route /spoons/:id
    
  Scenario: create a spoon, go to its edit page, check lots of different refs to it
    Given a spoon: "fred" exists
    When I go to spoon: "fred"'s edit page
    Then I should be at the 1st spoon's edit page
    And the 1st spoon's edit page should match route /spoons/:id/edit
    And the spoon's edit page should match route /spoons/:id/edit
    And the spoon: "fred"'s edit page should match route /spoons/:id/edit
    
  Scenario: go to a fork's nested tines page
    Given a fork exists
    When I go to the fork's tines page
    Then I should be at the fork's tines page
    And the fork's tines page should match route /forks/:fork_id/tines
  
  Scenario: go to a fork's new tine page
    Given a fork exists
    When I go to the fork's new tine page
    Then I should be at the fork's new tine page
    And the fork's new tine page should match route /forks/:fork_id/tines/new
    
  Scenario: go to a tine in fork context page
    Given a fork exists
    And a tine exists with fork: the fork
    When I go to the fork's tine's page
    Then I should be at the fork's tine's page
    And the fork's tine's page should match route /forks/:fork_id/tines/:id
    
  Scenario: go to a tine's comments in fork context
    Given a fork exists
    And a tine exists with fork: the fork
    When I go to the fork's tine's comments page
    Then I should be at the fork's tine's comments page
    And the fork's tine's comments page should match route /forks/:fork_id/tines/:tine_id/comments