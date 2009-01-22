Feature: I can visit a path, and know when I'm at a path
  In order to nav in my featuers
  As a feature writer
  I want to be able visit paths, and test that I'm at them

  Scenario: visit a path
    When I go to /spoons/new
    Then I should be at /spoons/new
