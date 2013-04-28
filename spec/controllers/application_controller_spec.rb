# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

# on utilise Admin::NaturesController mais le but de cette spec est de faire les tests
# des actions before_filter de application_controller
describe Admin::OrganismsController do

  let(:cu) {mock_model(User)}
  let(:o) {mock_model(Organism)}
  let(:r) {mock_model(Room)}
  let(:p) {mock_model(Period)}

  
  describe 'before_filters' do

    before(:each) do

    end

    it 'should redirect without user (filter log_in?)' do
      get :index
      response.should redirect_to new_session_url
    end

    it 'assign user when session user (current_user)' do
      User.should_receive(:find_by_id).with(cu.id).and_return(cu)
      cu.stub_chain(:rooms, :map).and_return [1,2]
      get :index, {}, {user:cu.id}
      assigns(:user).should == cu
    end

    it 'connect to and look_for organism (find_organism)' do
      User.stub(:find_by_id).and_return cu
      Organism.stub(:first).and_return o
      o.stub_chain(:periods, :empty?).and_return true
      cu.stub(:rooms).and_return(@a = double(Arel))
      @a.should_receive(:find_by_database_name).with('assotest1').and_return r
      r.should_receive(:connect_to_organism)
      get :show, {id:1}, {user:cu.id, org_db:'assotest1'}
      assigns(:organism).should == o
    end

    it 'look for period when there is one (current_period)' do
      User.stub(:find_by_id).and_return cu
      Organism.stub(:first).and_return o
      
      cu.stub_chain(:rooms, :find_by_database_name).and_return(r)
      r.stub(:connect_to_organism)
      # 3 fois : 1 pour periods.empty?
      # 1 pour period.last
      o.should_receive(:periods).exactly(2).times.and_return(@a = double(Arel))
      @a.stub(:empty?).and_return(false)
      @a.should_receive(:last).and_return(p)
      get :show, {id:1}, {user:cu.id, org_db:'assotest1'}
      assigns(:period).should == p
      session[:period].should == p.id
    end

    it 'look for period from session when there is one (current_period)' do
      User.stub(:find_by_id).and_return cu
      Organism.stub(:first).and_return o
      cu.stub_chain(:rooms, :find_by_database_name).and_return(r)
      r.stub(:connect_to_organism)
      o.stub(:periods).and_return(@a=double(Arel))
      @a.stub(:empty?).and_return false
      @a.should_receive(:find_by_id).with(p.id).and_return p
      get :show, {id:1}, {user:cu.id, org_db:'assotest1', period:p.id}
      assigns(:period).should == p
      session[:period].should == p.id
    end

    

  end

  
end
