Feature: Note the pickle_ref's assoc

  Scenario: store a ref to a known object's property, for later reference
    Given an example active_record/orm app
    
    And step definitions:
      """
      Given(/^someone presses the 'WELCOME' button$/) do
        pickle.make('user').create_welcome_note
      end
      
      When(/^#{pickle_ref} presses his 'GDAY' button$/) do |ref|
        pickle.model(ref).create_note "G'day"
      end
      """
    
    Then the following steps should pass:
      """
      Given someone presses the 'WELCOME' button
      Then there should be a note
      And notice the note's owner "Fred"
      
      When "Fred" presses his 'GDAY' button
      Then "Fred" should have 2 notes
      """