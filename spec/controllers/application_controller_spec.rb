# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
 # c.filter = {:wip=>true}
end

# on utilise Admin::PeriodsController mais le but de cette spec est de faire les tests
# des actions before_filter de application_controller
describe Admin::PeriodsController do
  include SpecControllerHelper
  let(:cu) {mock_model(User, 'up_to_date?'=>true)}
  let(:o) {mock_model(Organism)}
  let(:r1) {mock_model(Room)}
  let(:r2) {mock_model(Room)}
  let(:p) {mock_model(Period)}

  
  describe 'before_filters' do

    describe 'sign_in' do


      it 'should redirect without user (filter log_in?)' do
        sign_in(nil)
        get :index #'on utilise une action quelconque (ici rooms)'
        response.should redirect_to new_user_session_url
      end
    
      it 'assign user si la session existe' do
        cu.stub_chain(:rooms, :count).and_return 2
        sign_in(cu)

        get :index
        response.should redirect_to admin_rooms_url
      end

    end

    context 'signed' do


      before(:each) do
        sign_in(cu)
        cu.stub_chain(:rooms, :count).and_return 2
      end


      describe 'find_organism'  do
      
        it 'pas d organisme si pas de session de org_db' do
          get :index, { :action=>'admin/rooms'}
          assigns(:organism).should == nil
        end

        it 'si session[:org_db, cherche la chambre et assigne @organism' do
          cu.should_receive(:rooms).and_return(@ar = double(Arel))
          @ar.should_receive(:find_by_database_name).with('bonjour').and_return(r1)
          r1.stub(:connect_to_organism).and_return true
          
        
        get :index, {}, {org_db:'bonjour'}
          assigns(:organism).should == @o
        end

        it 'si un seul organisme renvoie vers show' do
          cu.stub_chain(:rooms, :count).and_return 2
          get :index, { :action=>'admin/rooms'}
          assigns(:organism).should == nil
          response.should redirect_to admin_rooms_url
        end
      end


      describe 'current_period' do
      
        before(:each) do
          Organism.stub(:first).and_return o
        end
      
        it 'rien sans organisme' do
          get :index, {}
          assigns(:period).should be_nil
        end



    
        it 'look for period when there is no session period' do
            
          cu.stub_chain(:rooms, :find_by_database_name).and_return(r1)
          r1.stub(:connect_to_organism)
          # 3 fois : 1 pour periods.empty?
          # 1 pour period.last
          o.should_receive(:periods).exactly(3).times.and_return(@a = double(Arel))
          @a.stub(:empty?).and_return(false)
          @a.should_receive(:last).and_return(p)
          get :index, {}, {user:cu.id, org_db:'assotest1'}
          assigns(:period).should == p
          session[:period].should == p.id
        end

        it 'look for period from session when there is one (current_period)' do

          cu.stub_chain(:rooms, :find_by_database_name).and_return(r1)
          r1.stub(:connect_to_organism)
          o.should_receive(:periods).exactly(2).times.and_return(@a=double(Arel))
          @a.should_receive(:find_by_id).with(p.id).and_return p
          get :index,{}, {user:cu.id, org_db:'assotest1', period:p.id}
          assigns(:period).should == p
          session[:period].should == p.id
        end

      end

    describe 'sign_out' do

      it 'renvoie vers la page bye quand on se déloggue' do
          pending 'à faire'

        end
    end


    

    end
  end
  
end
