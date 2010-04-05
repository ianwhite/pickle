Feature: I can test emails are sent
  In order write features with emails as outcomes
  As a feature writer
  I want to easily see what emails have been delivered
  
  Scenario: Deliver an email, and test it's properties
    Given an email "Gday" with body: "Gday Mate" is delivered to fred@gmail.com
    Then 1 email should be delivered
    And the email should not be delivered to "frood@fmail.com"
    And the email should have subject: "Gday", to: "fred@gmail.com"
    And the email should contain "Mate"
    And the email should not contain "Foo"
    
  Scenario: Deliver some emails, restrict scope
    Given an email "cool" with body: "body1" is delivered to fred@gmail.com
    And an email "tasty" with body: "body2" is delivered to fred@gmail.com
    And an email "cool" with body: "body3" is delivered to joe@gmail.com
    
    Then 2 emails should be delivered to fred@gmail.com
    And the 1st email should have subject: "cool"
    And the 2nd email should have subject: "tasty"
    
    And 2 emails should be delivered with subject: "cool"
    And the 1st email should be delivered to fred@gmail.com
    And the 2nd email should be delivered to joe@gmail.com
    
    And 1 email should be delivered with subject: "cool", to: "fred@gmail.com"
    
  Scenario: Deliver some emails, reset deliveries
    Given an email "cool" with body: "body1" is delivered to fred@gmail.com
    And all emails have been delivered
    Then 0 emails should be delivered
    
  Scenario: Deliver emails to user
    Given a user exists with name: "Fred", email: "fred@gmail.com"
    And the user's email is delivered
    Then 1 email should be delivered to the user
    And the email should contain "Dear Fred"
    And the email should link to the user's page

  Scenario: Following the first link in an email
  	Given a user exists with name: "Fred", email: "fred@gmail.com"
  	And an email "cool" with body: "some text <a href='http://example.com/users/1'>example page</a> more text" is delivered to fred@gmail.com
    Then 1 email should be delivered to the user
		And I click the first link in the email
		Then I should be at the user's page

  Scenario: Following a link in an email by url
  	Given a user exists with name: "Fred", email: "fred@gmail.com"
  	And an email "cool" with body: "some text <a href='http://example.com/users/1'>example page</a> more text" is delivered to fred@gmail.com
    Then 1 email should be delivered to the user
		And I follow "example.com/" in the email
		Then I should be at the user's page

  Scenario: Following a link in an email by the text
  	Given a user exists with name: "Fred", email: "fred@gmail.com"
  	And an email "cool" with body: "some text <a href='http://example.com/users/1'>example page</a> more text" is delivered to fred@gmail.com
    Then 1 email should be delivered to the user
		And I follow "example page" in the email
		Then I should be at the user's page
		
  Scenario: Save and open email 
    Given an email "Gday" with body: "Gday Mate" is delivered to fred@gmail.com
    Then show me the email
