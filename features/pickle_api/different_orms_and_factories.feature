Feature: Example of the pickle api, testing that it works (in exactly the same way) with different combinations of orm and factory

  Scenario Outline:
    Given I create an example <ORM> app
    And I am using <FACTORY> for generating test data
    And I am writing a test using the pickle dsl
    And notice the code is the same even though the orm is <ORM> and the factory is <FACTORY>
    
    Then I can make and store a user (code):
    """
      user = pickle.make_and_store 'a user'
    """
    
    And the result is a user made by <FACTORY> (code):
    """
      user.should be_a User
      user.name.should == "made by <FACTORY>"
    """
      
    Then the exact user object can be retrieved from the session (code):
    """
      pickle.retrieve('the user').object_id.should == user.object_id
    """
    
    And the reloaded user can be retrieved from the db (code):
    """
      pickle.retrieve_and_reload('the user').should == user
    """
    
    And pickle.model does the same thing as pickle.retrieve_and_reload (code):
    """
      pickle.model('the user').should == user
    """
      
    And in our example app, creating a user creates an associated note, pickle can find and store it (code):
    """
      welcome_note = pickle.find_and_store 'note: "welcome note"', 'owner: the user'
    """

    Then it should be a note, lets use the adapter to find and compare it (code):
    """
      welcome_note.should be_a Note
      
      # adapter_for will find with the <ORM> orm_adpater in this case
      pickle.adapter_for('note').get(welcome_note.id).should == welcome_note
    """
    
    And we can use the following ways to get the note (code):
    """
      pickle.model('the note').should == welcome_note
      pickle.model('note "welcome note"').should == welcome_note
      pickle.model('"welcome note"').should == welcome_note
      pickle.model(:factory => 'note').should == welcome_note
      pickle.model(:label => 'welcome note').should == welcome_note
    """
    
    When we create another note manually, we can store it in pickle ourselves (code):
    """
      another_note = user.notes.create
      pickle.store another_note
    """
    
    Then we can get the notes back in the order they were mentioned, just like a conversation (code):
    """
      pickle.model('the 1st note').should == welcome_note
      pickle.model('the 2nd note').should == another_note
    """

  Examples:
    | ORM           | FACTORY       |
    | active_record | orm           |
    | active_record | factory_girl  |
    | active_record | machinist     |
    | data_mapper   | orm           |
    | data_mapper   | factory_girl  |
    | data_mapper   | machinist     |
    | mongoid       | orm           |
    | mongoid       | factory_girl  |
    | mongoid       | machinist     |