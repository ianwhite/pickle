require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Path do
  include Pickle::Path
  
  before do
    stub!(:model).and_return(@user = mock_model(User))
  end
  
  describe "#path_to_pickle" do
    it "('a user', 'the user: \"fred\"') should retrieve 'a user', and 'the user: \"fred\"' models" do
      should_receive(:model).with('a user')
      should_receive(:model).with('the user: "fred"')
      stub!(:user_user_path).and_return('the path')
      path_to_pickle 'a user', 'the user: "fred"'
    end
    
    it "('a user', :action => 'foo') should return foo_user_path(<user>)" do
      should_receive(:foo_user_path).with(@user).and_return('the path')
      path_to_pickle('a user', :action => 'foo').should == 'the path'
    end
    
    it "('a user', :action => 'foo') should raise informative error if foo_user_path not defined" do
      should_receive(:foo_user_path).with(@user).and_raise(NoMethodError)
      lambda { path_to_pickle('a user', :action => 'foo') }.should raise_error(Exception, /Could not figure out a path for/)
    end
    
    it "('a user', :segment => 'foo') should return user_foo_path(<user>)" do
      should_receive(:user_foo_path).with(@user).and_return('the path')
      path_to_pickle('a user', :segment => 'foo').should == 'the path'
    end
    
    it "('a user', :segment => 'foo') should raise informative error if foo_user_path not defined" do
      should_receive(:user_foo_path).with(@user).and_raise(NoMethodError)
      lambda { path_to_pickle('a user', :segment => 'foo') }.should raise_error(Exception, /Could not figure out a path for/)
    end
    
    it "('a user', :action => 'new', :segment => 'comment') should return new_user_comment_path(<user>)" do
      should_receive(:new_user_comment_path).with(@user).and_return('the path')
      path_to_pickle('a user', :segment => 'comment', :action => 'new').should == 'the path'
    end
    
    it "('a user', :action => 'new', :segment => 'comment') should raise informative error if new_user_comment_path not defined" do
      should_receive(:new_user_comment_path).with(@user).and_raise(NoMethodError)
      lambda { path_to_pickle('a user', :action => 'new', :segment => 'comment') }.should raise_error(Exception, /Could not figure out a path for/)
    end
    
    it "('a user', :extra => 'new comment') should return new_user_comment_path(<user>)" do
      should_receive(:new_user_comment_path).with(@user).and_return('the path')
      path_to_pickle('a user', :extra => 'new comment').should == 'the path'
    end
    
    it "('a user', :extra => 'new comment') should raise informative error if new_user_comment_path not defined" do
      should_receive(:new_user_comment_path).with(@user).and_raise(NoMethodError)
      lambda { path_to_pickle('a user', :extra => 'new comment') }.should raise_error(Exception, /Could not figure out a path for/)
    end
    
    describe "(private API)" do
      it "('a user', :extra => 'new ish comment') should try combinations of 'new', 'ish', 'comment'" do
        should_receive(:pickle_path_for_models_action_segment).with([@user], '', 'new_ish_comment').once
        should_receive(:pickle_path_for_models_action_segment).with([@user], 'new', 'ish_comment').once
        should_receive(:pickle_path_for_models_action_segment).with([@user], 'new_ish', 'comment').once
        should_receive(:pickle_path_for_models_action_segment).with([@user], 'new_ish_comment', '').once
        lambda { path_to_pickle('a user', :extra => 'new ish comment') }.should raise_error(Exception, /Could not figure out a path for/)
      end
    end
  end
end