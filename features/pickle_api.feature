Feature: Example of the pickle api, testing that it works with different combinations of orm and factory

  Scenario Outline:
    Given an example <ORM>/<FACTORY> app
    Then the following spec should pass:
      """
      # I can make and store a user, and the result is a user made by <FACTORY>:
      user = pickle.make_and_store 'a user'
      user.should be_a User
      user.name.should == "made by <FACTORY>"
      
      # I can retrieve (original stored object) or retrieve_and_reload, aliased as model, the object using a pickle ref:
      pickle.retrieve('the user').object_id.should == user.object_id
      pickle.retrieve_and_reload('the user').should == user
      pickle.model('the user').should == user
      
      # something happens that changes the db, then pickle can find and store the expected changes:
      user.create_welcome_note
      
      welcome_note = pickle.find_and_store 'note: "welcome note"', 'owner: the user'
      welcome_note.should be_a Note
      
      # adapter_for will find with the <ORM> orm_adpater in this case
      pickle.adapter_for('note').get(welcome_note.id).should == welcome_note
      
      # we can use the following ways to get the note:
      pickle.model('the note').should == welcome_note
      pickle.model('note "welcome note"').should == welcome_note
      pickle.model('"welcome note"').should == welcome_note
      pickle.model('1st note').should == welcome_note
      pickle.model(:factory => 'note').should == welcome_note
      pickle.model(:label => 'welcome note').should == welcome_note
      pickle.model(:factory => 'note', :index => 0).should == welcome_note

      # we create another note, we can store it in pickle ourselves, then retrieve in the order they were mentioned, just like a conversation:
      another_note = user.create_note("another note")
      pickle.store another_note

      pickle.model('the 1st note').should == welcome_note
      pickle.model('the 2nd note').should == another_note
      """
    
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