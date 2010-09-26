Feature: Example of the pickle steps, testing with different combinations of orm and factory

  Scenario Outline:
    Given I create an example <ORM> app
    And I am using <FACTORY> (<ORM>) for generating test data
    And I am writing features using pickle, <FACTORY> (<ORM>) and the following config:
      """
      Pickle.config.map_label_for 'user', :to => 'name'
      """
      
    And a feature "simple" with:
      """
      Feature: simple
      
        Scenario: simple
          Given there is a user "Fred"
          And there is a user with name: "not labelled"
          And there are the following users:
            | user  | name      |
            | Betty | Elizabeth |
            | Liz   | Elizabeth |
      
          Then "Fred" should be the 1st user
          And "Fred"'s name should be 'Fred'
      
          Then there should be at most 2 users with name: "not labelled"
          And the last user should be the 2nd user
          And last user's name should be the same as the 2nd user's name
      
          And "Betty" should be the 3rd user
          And "Betty"'s name should be "Elizabeth"
          And "Liz" should be the 4th user
          And the user "Liz"'s name should be 'Elizabeth'
          And user: "Liz"'s name should be user: "Betty"'s name
      
          But "Fred"'s name should not be the same as "Betty"'s name
      """
      
    Then running the "simple" feature should pass
      
  Examples:
    | ORM           | FACTORY      |
    | active_record | machinist    |
    | active_record | factory_girl |
    | active_record | orm          |
    | data_mapper   | machinist    |
    | data_mapper   | factory_girl |
    | data_mapper   | orm          |
    | mongoid       | machinist    |
    | mongoid       | factory_girl |
    | mongoid       | orm          |