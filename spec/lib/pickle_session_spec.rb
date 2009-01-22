require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Pickle::Session do
  include Pickle::Session
  
  describe "Pickle::Session proxy missing methods to parser", :shared => true do
    it "should forward to pickle_parser it responds_to them" do
      @it.pickle_parser.should_receive(:parse_model)
      @it.parse_model
    end

    it "should raise error if pickle_parser don't know about em" do
      lambda { @it.parse_infinity }.should raise_error
    end
  end

  describe "including Pickle::Session" do
    before do 
      @it = self
    end
    
    it_should_behave_like "Pickle::Session proxy missing methods to parser"
  end

  describe "extending Pickle::Session" do
    before do 
      @it = Object.new
      @it.extend Pickle::Session
    end
    
    it_should_behave_like "Pickle::Session proxy missing methods to parser"
  end

  describe "after storing a single user", :shared => true do
    it "created_models('user') should be array containing the original user" do
      created_models('user').should == [@user]
    end

    describe "the original user should be retrievable with" do
      it "created_model('the user')" do
        created_model('the user').should == @user
      end

      it "created_model('1st user')" do
        created_model('1st user').should == @user
      end

      it "created_model('last user')" do
        created_model('last user').should == @user
      end
    end

    describe "(found from db)" do
      before do
        @user.stub!(:id).and_return(100)
        @user.class.should_receive(:find).with(100).and_return(@user_from_db = @user.dup)
      end
    
      it "models('user') should be array containing user" do
        models('user').should == [@user_from_db]
      end
  
      describe "user should be retrievable with" do
        it "model('the user')" do
          model('the user').should == @user_from_db
        end

        it "model('1st user')" do
          model('1st user').should == @user_from_db
        end

        it "model('last user')" do
          model('last user').should == @user_from_db
        end
      end
    end
  end
  
  describe "#create_model" do
    before do
      @user = mock_model(User)
      Factory.stub!(:create).and_return(@user)
    end
    
    describe "('a user')" do
      def do_create_model
        create_model('a user')
      end
  
      it "should call Factory.create('user', {})" do
        Factory.should_receive(:create).with('user', {}).and_return(@user)
        do_create_model
      end
      
      describe "after create," do
        before { do_create_model }
        
        it_should_behave_like "after storing a single user"
      end
    end
    
    describe "('1 user', 'foo: \"bar\", baz: \"bing bong\"')" do
      def do_create_model
        create_model('1 user', 'foo: "bar", baz: "bing bong"')
      end
  
      it "should call Factory.create('user', {'foo' => 'bar', 'baz' => 'bing bong'})" do
        Factory.should_receive(:create).with('user', {'foo' => 'bar', 'baz' => 'bing bong'}).and_return(@user)
        do_create_model
      end
      
      describe "after create," do
        before { do_create_model }
        
        it_should_behave_like "after storing a single user"
      end
    end  

    describe "('an user: \"fred\")" do
      def do_create_model
        create_model('an user: "fred"')
      end
  
      it "should call Factory.create('user', {})" do
        Factory.should_receive(:create).with('user', {}).and_return(@user)
        do_create_model
      end
      
      describe "after create," do
        before { do_create_model }
        
        it_should_behave_like "after storing a single user"
              
        it "created_model('the user: \"fred\"') should retrieve the user" do
          created_model('the user: "fred"').should == @user
        end
      
        it "created_model?('the user: \"shirl\"') should be false" do
          created_model?('the user: "shirl"').should == false
        end
        
        it "model?('the user: \"shirl\"') should be false" do
          model?('the user: "shirl"').should == false
        end
      end
    end  
  end

  describe '#find_model' do
    before do
      @user = mock_model(User)
      User.stub!(:find).and_return(@user)
    end
    
    def do_find_model
      find_model('a user', 'hair: "pink"')
    end
    
    it "should call User.find :first, :conditions => {'hair' => 'pink'}" do
      User.should_receive(:find).with(:first, :conditions => {'hair' => 'pink'}).and_return(@user)
      do_find_model
    end
    
    describe "after find," do
      before { do_find_model }
      
      it_should_behave_like "after storing a single user"
    end
  end
  
  describe "#find_models" do
    before do
      @user = mock_model(User)
      User.stub!(:find).and_return([@user])
    end

    def do_find_models
      find_models('user', 'hair: "pink"')
    end

    it "should call User.find :all, :conditions => {'hair' => 'pink'}" do
      User.should_receive(:find).with(:all, :conditions => {'hair' => 'pink'}).and_return([@user])
      do_find_models
    end

    describe "after find," do
      before { do_find_models }

      it_should_behave_like "after storing a single user"
    end
  end
    
  describe 'creating \'a super admin: "fred"\', then \'a user: "shirl"\', \'then 1 super_admin\'' do
    before do
      @user = @fred = mock_model(User)
      @shirl  = mock_model(User)
      @noname = mock_model(User)
      Factory.stub!(:create).and_return(@fred, @shirl, @noname)
    end
    
    def do_create_users
      create_model('a super admin: "fred"')
      create_model('a user: "shirl"')
      create_model('1 super_admin')
    end
    
    it "should call Factory.create with <'super_admin'>, <'user'>, <'super_admin'>" do
      Factory.should_receive(:create).with('super_admin', {}).twice
      Factory.should_receive(:create).with('user', {}).once
      do_create_users
    end
    
    describe "after create," do
      before do
        do_create_users
      end
      
      it "created_models('user') should == [@fred, @shirl, @noname]" do
        created_models('user').should == [@fred, @shirl, @noname]
      end
      
      it "created_models('super_admin') should == [@fred, @noname]" do
        created_models('super_admin').should == [@fred, @noname]
      end
      
      describe "#created_model" do
        it "'that user' should be @noname (the last user created - as super_admins are users)" do
          created_model('that user').should == @noname
        end

        it "'the super admin' should be @noname (the last super admin created)" do
          created_model('that super admin').should == @noname
        end
        
        it "'the 1st super admin' should be @fred" do
          created_model('the 1st super admin').should == @fred
        end
        
        it "'the first user' should be @fred" do
          created_model('the first user').should == @fred
        end
        
        it "'the 2nd user' should be @shirl" do
          created_model('the 2nd user').should == @shirl
        end
        
        it "'the last user' should be @noname" do
          created_model('the last user').should == @noname
        end
        
        it "'the user: \"fred\" should be @fred" do
          created_model('the user: "fred"').should == @fred
        end
        
        it "'the user: \"shirl\" should be @shirl" do
          created_model('the user: "shirl"').should == @shirl
        end
      end
    end
  end

  describe "when 'the user: \"me\"' exists and there is a mapping from 'I', 'myself' => 'user: \"me\"" do
    before do
      @user = mock_model(User)
      User.stub!(:find).and_return(@user)
      Factory.stub!(:create).and_return(@user)
      self.pickle_parser = Pickle::Parser.new(:config => Pickle::Config.new {|c| c.map 'I', 'myself', :to => 'user: "me"'})
      create_model('the user: "me"')
    end
  
    it 'model("I") should return the user' do
      model('I').should == @user
    end

    it 'model("myself") should return the user' do
      model('myself').should == @user
    end
    
    it "#parser.parse_fields 'author: user \"JIM\"' should raise Error, as model deos not refer" do
      lambda { pickle_parser.parse_fields('author: user "JIM"') }.should raise_error
    end
    
    it "#parser.parse_fields 'author: the user' should return {\"author\" => <user>}" do
      pickle_parser.parse_fields('author: the user').should == {"author" => @user}
    end

    it "#parser.parse_fields 'author: myself' should return {\"author\" => <user>}" do
      pickle_parser.parse_fields('author: myself').should == {"author" => @user}
    end
    
    it "#parser.parse_fields 'author: the user, approver: I, rating: \"5\"' should return {'author' => <user>, 'approver' => <user>, 'rating' => '5'}" do
      pickle_parser.parse_fields('author: the user, approver: I, rating: "5"').should == {'author' => @user, 'approver' => @user, 'rating' => '5'}
    end
    
    it "#parser.parse_fields 'author: user: \"me\", approver: \"\"' should return {'author' => <user>, 'approver' => \"\"}" do
      pickle_parser.parse_fields('author: user: "me", approver: ""').should == {'author' => @user, 'approver' => ""}
    end
  end
  
  describe "convert_models_to_attributes(ar_class, :user => <a user>)" do
    before do 
      @user = mock_model(User)
    end
    
    describe "(when ar_class has column 'user_id')" do
      before do
        @ar_class = mock('ActiveRecord', :column_names => ['user_id'])
      end
      
      it "should return {'user_id' => <the user.id>}" do
        convert_models_to_attributes(@ar_class, :user => @user).should == {'user_id' => @user.id}
      end
    end
    
    describe "(when ar_class has columns 'user_id', 'user_type')" do
      before do
        @ar_class = mock('ActiveRecord', :column_names => ['user_id', 'user_type'])
      end
      
      it "should return {'user_id' => <the user.id>, 'user_type' => <the user.type>}" do
        convert_models_to_attributes(@ar_class, :user => @user).should == {'user_id' => @user.id, 'user_type' => @user.class.name}
      end
    end
  end
end