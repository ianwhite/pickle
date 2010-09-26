require 'spec_helper'

describe 'Session API' do
  subject do
    Object.new.tap do |obj|
      obj.extend Pickle::Session::Api
      obj.stub!(:config).and_return Pickle::Config.new
      obj.stub!(:jar).and_return Pickle::Jar.new
    end
  end

  let(:model) {mock('model')}
  
  describe "[stub assumptions]" do
    specify "has a #config (Pickle::Config)" do
      subject.config.should be_a Pickle::Config
    end

    specify "has a #jar (Pickle::Jar)" do
      subject.jar.should be_a Pickle::Jar
    end
  end

  describe "(storing)" do
    specify "#store(model) stores the model using a pickle ref corresponding to the model's class name" do
      subject.jar.should_receive(:store).with(model, Pickle::Ref.new(model.class.name))
      subject.store model
    end
  
    specify "#store(model, 'user') stores the model using a pickle ref corresponding to 'user'" do
      subject.jar.should_receive(:store).with(model, Pickle::Ref.new('user'))
      subject.store model, 'user'
    end
    
    specify "#store(model, '1st user') raises InvalidPickleRefError (because you can't store specifying an index)" do
      lambda { subject.store model, '1st user' }.should raise_error Pickle::InvalidPickleRefError
    end
  end
  
  describe "(retrieving)" do
    describe " #retrieve('the user')" do
      specify "when something exists in the jar corresponding to the pickle ref, should return the object" do
        subject.jar.should_receive(:retrieve).with(Pickle::Ref.new('the user')).and_return(model)
        subject.retrieve('the user').should == model
      end
    
      specify "when the jar raises UnknownModelError, should reraise with info" do
        lambda {subject.retrieve 'the user'}.should raise_error(Pickle::UnknownModelError, /is not known in this session/)
      end
    end
  
    shared_examples_for 'retrieve_and_reload' do
      specify "should retrieve 'the user', reload and return it" do
        subject.should_receive(:retrieve).with('the user').and_return(model)
        subject.should_receive(:reload).with(model).and_return(model)
        subject.send(the_method, 'the user').should == model
      end
    end
  
    describe " #retrieve_and_reload('the user')" do
      let(:the_method) { :retrieve_and_reload }
      it_should_behave_like 'retrieve_and_reload'
    end
  
    describe " #model('the user')" do
      let(:the_method) { :model }
      it_should_behave_like 'retrieve_and_reload'
    end
  
    specify "#known?('the user') returns whether the jar includes an object correpsonding to the pickle ref" do
      subject.jar.should_receive(:include?).with(Pickle::Ref.new('the user')).and_return(whether_jar_includes_it = mock)
      subject.known?('the user').should == whether_jar_includes_it
    end
  end

  describe "(making)" do
    specify "#make_and_store('the user') makes a model using the pickle_ref, stores it in the jar, and returns it" do
      subject.should_receive(:make).with(Pickle::Ref.new('user'), {}).and_return(model)
      subject.jar.should_receive(:store).with(model, Pickle::Ref.new('user')).and_return(result = mock)
      subject.make_and_store('the user').should == result
    end
   
    specify "#make_and_store('the user: \"fred\"', 'age: 23') makes a model using the pickle_ref, and fields converted to attributes, and store it in the jar" do
      subject.should_receive(:make).with(Pickle::Ref.new('user "fred"'), 'age' => 23).and_return(model)
      subject.jar.should_receive(:store).with(model, Pickle::Ref.new('user "fred"'))
      subject.make_and_store 'the user: "fred"', 'age: 23'
    end
  
    specify "#make_and_store('1st user') raises InvalidPickleRefError (because you can't store specifying an index)" do
      subject.stub!('make')
      lambda { subject.make_and_store '1st user' }.should raise_error Pickle::InvalidPickleRefError
    end
    
    describe '(when config has label mapping to "name" for "user") ' do
      before { subject.config.map_label_for 'user', :to => 'name' }
    
      describe "Cases where label is used for name:" do
        [ 
          %Q{make_and_store('user "fred"')},
          %Q{make_and_store('user "fred"', 'age: 23')},
          %Q{make_and_store('user "fred"', :age => 23)},
          %Q{make_and_store(:factory => 'user', :label => "fred")},
          %Q{make_and_store({:factory => 'user', :label => "fred"}, 'age: 23')},
          %Q{make_and_store({:factory => 'user', :label => "fred"}, :age => 23)}       
        ].each do |example|
          it '#' + example do
            subject.should_receive(:make).with(anything, hash_including('name' => 'fred'))
            subject.instance_eval example
          end
        end
      end
    
      describe "Cases where label is ignored:" do
        [ 
          %Q{make_and_store('user "fred"', 'name: "george"')},
          %Q{make_and_store('user "fred"', :name => "george")},
          %Q{make_and_store('product "fred"')},
          %Q{make_and_store('user')}
        ].each do |example|
          it '#' + example do
            subject.should_receive(:make).with(anything, hash_not_including('name' => 'fred'))
            subject.instance_eval example
          end
        end
      end
    end
  end
  
  describe "(finding first)" do
    specify "#find_and_store('the user') finds the first user model, stores it with the 'user' pickle_ref, and returns it" do
      subject.should_receive(:find_first).with(Pickle::Ref.new('user'), {}).and_return(model)
      subject.jar.should_receive(:store).with(model, Pickle::Ref.new('user')).and_return(result = mock)
      subject.find_and_store('the user').should == result
    end
    
    specify "#find_and_store('the user', 'age: 23') finds the first user model with the given conditions, and store it with the 'user' pickle_ref" do
      subject.should_receive(:find_first).with(Pickle::Ref.new('user'), {'age' => 23}).and_return(model)
      subject.jar.should_receive(:store).with(model, Pickle::Ref.new('user'))
      subject.find_and_store 'the user', 'age: 23'
    end
    
    specify "#find_and_store('1st user') raises InvalidPickleRefError (because you can't store specifying an index)" do
      subject.stub(:find_first)
      lambda { subject.find_and_store '1st user' }.should raise_error Pickle::InvalidPickleRefError
    end
  end
  
  describe "(finding all)" do
    let(:another_model) { mock }
    
    before do
      subject.jar.should_receive(:store).with(model, Pickle::Ref.new('user')).once.ordered
      subject.jar.should_receive(:store).with(another_model, Pickle::Ref.new('user')).once.ordered
    end
    
    specify "#find_all_and_store('users') finds all users, and stores them with pickle ref corresponding to 'user'" do
      subject.should_receive(:find_all).with(Pickle::Ref.new('user'), {}).and_return([model, another_model])
      subject.find_all_and_store 'users'
    end
    
    specify "#find_all_and_store('users') returns the found users" do
      subject.should_receive(:find_all).with(Pickle::Ref.new('user'), {}).and_return([model, another_model])
      subject.find_all_and_store('users').should == [model, another_model]
    end
    
    specify "#find_all_and_store('users', 'age: 23') finds all users with the given conditions, and stores them with pickle ref corresponding to 'user'" do
      subject.should_receive(:find_all).with(Pickle::Ref.new('user'), {'age' => 23}).and_return([model, another_model])
      subject.find_all_and_store('users', 'age: 23')
    end
  end
end