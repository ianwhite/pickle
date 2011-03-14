require 'spec_helper'

require 'pickle/path'

describe Pickle::Path do
  include Pickle::Path
  
  describe "#path_to_pickle, when the model doesn't exist" do
    before do
      stub!(:model).and_return(nil)
    end
    it "('that user', :extra => 'new comment') should raise the error raised by model!" do
      lambda { path_to_pickle "that user", "new comment" }.should raise_error(RuntimeError, 'Could not figure out a path for ["that user", "new comment"] {}')
    end
    
  end
  
  describe "#path_to_pickle" do
    describe "when model returns a user" do
      let :user_class do
        mock 'User', :name => 'User'
      end
      
      let :user do
        mock 'user', :class => user_class
      end
      
      before do
        stub!(:model).and_return(user)
      end
    
      it "('a user', 'the user: \"fred\"') should retrieve 'a user', and 'the user: \"fred\"' models" do
        should_receive(:model).with('a user')
        should_receive(:model).with('the user: "fred"')
        stub!(:user_user_path).and_return('the path')
        path_to_pickle('a user', 'the user: "fred"').should == 'the path'
      end
    
      it "('a user', :action => 'foo') should return foo_user_path(<user>)" do
        should_receive(:foo_user_path).with(user).and_return('the path')
        path_to_pickle('a user', :action => 'foo').should == 'the path'
      end
    
      it "('a user', :action => 'foo') should raise informative error if foo_user_path not defined" do
        should_receive(:foo_user_path).with(user).and_raise(NoMethodError)
        lambda { path_to_pickle('a user', :action => 'foo') }.should raise_error(Exception, /Could not figure out a path for/)
      end
    
      it "('a user', :segment => 'foo') should return user_foo_path(<user>)" do
        should_receive(:user_foo_path).with(user).and_return('the path')
        path_to_pickle('a user', :segment => 'foo').should == 'the path'
      end
    
      it "('a user', :segment => 'foo') should raise informative error if foo_user_path not defined" do
        should_receive(:user_foo_path).with(user).and_raise(NoMethodError)
        lambda { path_to_pickle('a user', :segment => 'foo') }.should raise_error(Exception, /Could not figure out a path for/)
      end
    
      it "('a user', :action => 'new', :segment => 'comment') should return new_user_comment_path(<user>)" do
        should_receive(:new_user_comment_path).with(user).and_return('the path')
        path_to_pickle('a user', :segment => 'comment', :action => 'new').should == 'the path'
      end
    
      it "('a user', :action => 'new', :segment => 'comment') should raise informative error if new_user_comment_path not defined" do
        should_receive(:new_user_comment_path).with(user).and_raise(NoMethodError)
        lambda { path_to_pickle('a user', :action => 'new', :segment => 'comment') }.should raise_error(Exception, /Could not figure out a path for/)
      end
    
      it "('a user', :extra => 'new comment') should return new_user_comment_path(<user>)" do
        should_receive(:new_user_comment_path).with(user).and_return('the path')
        path_to_pickle('a user', :extra => 'new comment').should == 'the path'
      end
    
      it "('a user', :extra => 'new comment') should raise informative error if new_user_comment_path not defined" do
        should_receive(:new_user_comment_path).with(user).and_raise(NoMethodError)
        lambda { path_to_pickle('a user', :extra => 'new comment') }.should raise_error(Exception, /Could not figure out a path for/)
      end
      
      describe "when args is a list of pickle and non pickle models" do
        before do
          stub!(:model).with("account").and_return(nil)
        end
      
        it "('account', 'the user') should return account_user_path(<user>)" do
          should_receive(:account_user_path).with(user).and_return("the path")
          path_to_pickle('account', 'the user').should == 'the path'
        end
      end
      
      describe "(private API)" do
        it "('a user', :extra => 'new ish comment') should try combinations of 'new', 'ish', 'comment'" do
          should_receive(:pickle_path_for_resources_action_segment).with([user], '', 'new_ish_comment').once
          should_receive(:pickle_path_for_resources_action_segment).with([user], 'new', 'ish_comment').once
          should_receive(:pickle_path_for_resources_action_segment).with([user], 'new_ish', 'comment').once
          should_receive(:pickle_path_for_resources_action_segment).with([user], 'new_ish_comment', '').once
          lambda { path_to_pickle('a user', :extra => 'new ish comment') }.should raise_error(Exception, /Could not figure out a path for/)
        end
      end
    end
  end
end