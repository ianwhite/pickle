require 'spec_helper'

describe 'ActiveRecord PickleOrmAdapter' do
  it "should know how to convert attributes with model objects as values into conditions"

  #adapter could know how to 
  #
  # 'Then a site should exist with name: "Foo", owner: user "fred"'
  # 
  #  Conversion
  #   'name: "Foo", owner: user "fred"'
  #   {:name => "Foo", :owner => <User(fred)>}
  #   
  #  Adapter
  #    AR
  #      first(:conditions => {:name => "Foo", :owner_id => fred.id, :owner_type => 'User'})
  #  
end
