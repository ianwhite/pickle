# typed: true
require 'spec_helper'

require 'pickle/path'

describe Pickle::Path do
  include Pickle::Path

  describe "#path_to_pickle, when the model doesn't exist" do
    before do
      allow(self).to receive(:model).and_return(nil)
    end
    it "('that user', :extra => 'new comment') should raise the error raised by model!" do
      expect { path_to_pickle "that user", "new comment" }.to raise_error(RuntimeError, 'Could not figure out a path for ["that user", "new comment"] {}')
    end

  end

  describe "#path_to_pickle" do
    describe "when model returns a user" do
      let :user_class do
        double 'User', :name => 'User'
      end

      let :user do
        double 'user', :class => user_class
      end

      before do
        allow(self).to receive(:model).and_return(user)
      end

      it "('a user', 'the user: \"fred\"') should retrieve 'a user', and 'the user: \"fred\"' models" do
        expect(self).to receive(:model).with('a user')
        expect(self).to receive(:model).with('the user: "fred"')
        allow(self).to receive(:user_user_path).and_return('the path')
        expect(path_to_pickle('a user', 'the user: "fred"')).to eq('the path')
      end

      it "('a user', :action => 'foo') should return foo_user_path(<user>)" do
        expect(self).to receive(:foo_user_path).with(user).and_return('the path')
        expect(path_to_pickle('a user', :action => 'foo')).to eq('the path')
      end

      it "('a user', :action => 'foo') should raise informative error if foo_user_path not defined" do
        expect(self).to receive(:foo_user_path).with(user).and_raise(NoMethodError)
        expect { path_to_pickle('a user', :action => 'foo') }.to raise_error(Exception, /Could not figure out a path for/)
      end

      it "('a user', :segment => 'foo') should return user_foo_path(<user>)" do
        expect(self).to receive(:user_foo_path).with(user).and_return('the path')
        expect(path_to_pickle('a user', :segment => 'foo')).to eq('the path')
      end

      it "('a user', :segment => 'foo') should raise informative error if foo_user_path not defined" do
        expect(self).to receive(:user_foo_path).with(user).and_raise(NoMethodError)
        expect { path_to_pickle('a user', :segment => 'foo') }.to raise_error(Exception, /Could not figure out a path for/)
      end

      it "('a user', :action => 'new', :segment => 'comment') should return new_user_comment_path(<user>)" do
        expect(self).to receive(:new_user_comment_path).with(user).and_return('the path')
        expect(path_to_pickle('a user', :segment => 'comment', :action => 'new')).to eq('the path')
      end

      it "('a user', :action => 'new', :segment => 'comment') should raise informative error if new_user_comment_path not defined" do
        expect(self).to receive(:new_user_comment_path).with(user).and_raise(NoMethodError)
        expect { path_to_pickle('a user', :action => 'new', :segment => 'comment') }.to raise_error(Exception, /Could not figure out a path for/)
      end

      it "('a user', :extra => 'new comment') should return new_user_comment_path(<user>)" do
        expect(self).to receive(:new_user_comment_path).with(user).and_return('the path')
        expect(path_to_pickle('a user', :extra => 'new comment')).to eq('the path')
      end

      it "('a user', :extra => 'new comment') should raise informative error if new_user_comment_path not defined" do
        expect(self).to receive(:new_user_comment_path).with(user).and_raise(NoMethodError)
        expect { path_to_pickle('a user', :extra => 'new comment') }.to raise_error(Exception, /Could not figure out a path for/)
      end

      describe "when args is a list of pickle and non pickle models" do
        before do
          allow(self).to receive(:model).with("account").and_return(nil)
        end

        it "('account', 'the user') should return account_user_path(<user>)" do
          expect(self).to receive(:account_user_path).with(user).and_return("the path")
          expect(path_to_pickle('account', 'the user')).to eq('the path')
        end
      end

      describe "(private API)" do
        it "('a user', :extra => 'new ish comment') should try combinations of 'new', 'ish', 'comment'" do
          expect(self).to receive(:pickle_path_for_resources_action_segment).with([user], '', 'new_ish_comment').once
          expect(self).to receive(:pickle_path_for_resources_action_segment).with([user], 'new', 'ish_comment').once
          expect(self).to receive(:pickle_path_for_resources_action_segment).with([user], 'new_ish', 'comment').once
          expect(self).to receive(:pickle_path_for_resources_action_segment).with([user], 'new_ish_comment', '').once
          expect { path_to_pickle('a user', :extra => 'new ish comment') }.to raise_error(Exception, /Could not figure out a path for/)
        end
      end
    end

    describe "when model returns namespaced user" do
      let :user_class do
        double 'User', :name => 'Admin::User'
      end

      let :user do
        double 'user', :class => user_class
      end

      before do
        allow(self).to receive(:model).and_return(user)
      end

      it "('a user', :action => 'foo') should return foo_admin_user_path(<user>)" do
        expect(self).to receive(:foo_admin_user_path).with(user).and_return('the path')
        expect(path_to_pickle('a user', :action => 'foo')).to eq('the path')
      end
    end
  end
end
