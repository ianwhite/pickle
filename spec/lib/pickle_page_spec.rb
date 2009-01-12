require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Page do
  include Pickle::Page
  
  describe "#find_path_for" do
    it "('a user', 'the user: \"fred\"') should retrieve 'a user', and 'the user: \"fred\"' models" do
      should_receive(:model).with('a user').and_return(mock_model(User))
      should_receive(:model).with('the user: "fred"').and_return(mock_model(User))
      stub!(:user_user_path).and_return('the path')
      find_path_for 'a user', 'the user: "fred"'
    end
    
    it "('a user', :action => 'foo') should return foo_user_path(<user>)" do
      stub!(:model).and_return(user = mock_model(User))
      should_receive(:foo_user_path).with(user).and_return('the path')
      find_path_for('a user', :action => 'foo').should == 'the path'
    end
    
    it "('a user', :action => 'foo') should raise informative error if foo_user_path not defined" do
      stub!(:model).and_return(user = mock_model(User))
      should_receive(:foo_user_path).with(user).and_raise(NoMethodError)
      lambda { find_path_for('a user', :action => 'foo') }.should raise_error(Exception, /Could not figure out a path for/)
    end
    
    it "('a user', :segment => 'foo') should return user_foo_path(<user>)" do
      stub!(:model).and_return(user = mock_model(User))
      should_receive(:user_foo_path).with(user).and_return('the path')
      find_path_for('a user', :segment => 'foo').should == 'the path'
    end
    
    it "('a user', :segment => 'foo') should raise informative error if foo_user_path not defined" do
      stub!(:model).and_return(user = mock_model(User))
      should_receive(:user_foo_path).with(user).and_raise(NoMethodError)
      lambda { find_path_for('a user', :segment => 'foo') }.should raise_error(Exception, /Could not figure out a path for/)
    end
    
    it "('a user', :action => 'new', :segment => 'comment') should return new_user_comment_path(<user>)" do
      stub!(:model).and_return(user = mock_model(User))
      should_receive(:new_user_comment_path).with(user).and_return('the path')
      find_path_for('a user', :segment => 'comment', :action => 'new').should == 'the path'
    end
    
    it "('a user', :action => 'new', :segment => 'comment') should raise informative error if new_user_comment_path not defined" do
      stub!(:model).and_return(user = mock_model(User))
      should_receive(:new_user_comment_path).with(user).and_raise(NoMethodError)
      lambda { find_path_for('a user', :action => 'new', :segment => 'comment') }.should raise_error(Exception, /Could not figure out a path for/)
    end
    
    it "('a user', :extra => 'new comment') should return new_user_comment_path(<user>)" do
      stub!(:model).and_return(user = mock_model(User))
      should_receive(:new_user_comment_path).with(user).and_return('the path')
      find_path_for('a user', :extra => 'new comment').should == 'the path'
    end
    
    it "('a user', :extra => 'new comment') should raise informative error if new_user_comment_path not defined" do
      stub!(:model).and_return(user = mock_model(User))
      should_receive(:new_user_comment_path).with(user).and_raise(NoMethodError)
      lambda { find_path_for('a user', :extra => 'new comment') }.should raise_error(Exception, /Could not figure out a path for/)
    end
    
    describe "(private API)" do
      it "should try combinations of (<action>, <segment>)" do
        stub!(:model).and_return(user = mock_model(User))
        should_receive(:path_for_models_action_segment).with([user], '', 'new_ish_comment').once
        should_receive(:path_for_models_action_segment).with([user], 'new', 'ish_comment').once
        should_receive(:path_for_models_action_segment).with([user], 'new_ish', 'comment').once
        should_receive(:path_for_models_action_segment).with([user], 'new_ish_comment', '').once
        lambda { find_path_for('a user', :extra => 'new ish comment') }.should raise_error(Exception, /Could not figure out a path for/)
      end
    end
  end
end