# -*- encoding : utf-8 -*-

require 'spec_helper'


RSpec.configure do |c|
  # c.filter = {:wip=> true }
end

describe Admin::OrganismsController do
  include SpecControllerHelper
 
  def valid_attributes
    {database_name:'assotest4', user_id:@cu.to_param}
  end

  def user_session
    {user:@cu.id}
  end

  before(:each) do
    minimal_instances
    # minimal instance donne @cu pour current_user et @r comme room
    @cu.stub('up_to_date?').and_return true
  end



  describe 'GET edit'  do
    it 'rend le template edit' do
    Organism.should_receive(:find).with('1').and_return(mock_model(Organism))
    get :edit, {id:'1'}, user_session
    response.should render_template 'edit'
    end 
  end

  describe 'PUT update' do
    before(:each) do
      Organism.stub(:find).and_return(@o = mock_model(Organism, update_attributes:true))
    end


    it 'cherche l organisme' do
      Organism.should_receive(:find).with('1').and_return(stub_model(Organism))
      put :update, {id:'1'}, user_session
    end
    
    it 'met à jour l organisme' do
      @o.should_receive(:update_attributes).with({'name'=>'Bizarre'}).and_return true
      put :update, {id:'1', organism:{name:'Bizarre'}}, user_session
    end

    it 'renvoie le formulaire si non sauvé' do
      @o.stub(:update_attributes).and_return false
       put :update, {id:'1', organism:{name:'Bizarre'}}, user_session
       response.should render_template 'edit'
    end

    it 'redirige vers l action index si sauvé' do
      put :update, {id:'1', organism:{name:'Bizarre'}}, user_session
       response.should redirect_to admin_organism_url(@o)
    end


  end

  describe 'GET new' do

    it 'rend le formulaire' do
      get :new, {}, user_session
      response.should render_template :new
    end
  end



  describe 'POST create', wip:true do
    before(:each) do
      Organism.stub(:new).and_return(@o = mock_model(Organism, create_db:true, :save=>true))
      # ApplicationController.stub(:current_user).and_return @cu
    end

    it 'si valid crée la pièce' do
      @cu.should_receive(:rooms).and_return(@a = double(Arel, :save=>true))
      @a.should_receive(:new).with(:database_name=>'test1').and_return @a
      @a.should_receive(:connect_to_organism).and_return true
      post :create, {'organism'=>{'name'=>'Bizarre', 'database_name'=>'test1'}}, user_session
    end

    context 'quand room est correct' do

      before(:each) do
        @cu.stub_chain(:rooms, :new).and_return(@r = mock_model(Room, save:true, connect_to_organism:true).as_new_record)
      end

     it 'crée l organisme avec les paramètres' do
      Organism.should_receive(:new).with({'name'=>'Bizarre', 'database_name'=>'test1'}).and_return(stub_model(Organism))
      post :create, {'organism'=>{'name'=>'Bizarre', 'database_name'=>'test1'}}, user_session
    end

      it 'sauve l organisme et la pièce' do
      @o.should_receive(:save).and_return true
      @r.should_receive(:save).and_return true
      post :create, {'organism'=>{'name'=>'Bizarre' , 'database_name'=>'test1'}}, user_session
    end

      it 'redirige vers l action index si sauvé' do
       post :create, {'organism'=>{'name'=>'Bizarre', 'database_name'=>'test1'}}, user_session
       response.should redirect_to new_admin_organism_period_url(@o)
    end


    end

    context 'quand room est incorrect' do

      before(:each) do
        @cu.stub_chain(:rooms, :new).and_return(@r = mock_model(Room, save:false).as_new_record)
      end
   

    it 'renvoie le formulaire ' do
      post :create, {'organism'=>{'name'=>'Bizarre', 'database_name'=>'test1'}}, user_session
      response.should render_template :new
    end

    end

  end

 
  describe "GET index" do
    
    it "assigns all organisms  @organisme" do
      @cu.should_receive(:rooms).and_return(@a = double(Arel, :map=>[]))

      get :index,{}, user_session
      assigns(:organisms).should eq(@a)
    end

    it 'renders template index' do
      @cu.stub(:rooms).and_return(@a = double(Arel, :map=>[]))
      get :index,{}, user_session
      response.should render_template('index')
    end

    it 'si toutes les roome sont en phase n affiche pas de flash' do
      @cu.should_receive(:rooms).and_return([mock_model(Room, :relative_version=>:same_migration)])
      get :index,{}, user_session
      flash[:alert].should == nil
    end

    describe 'contrôle des flash' do
      
    before(:each) do
      @cu.stub(:rooms).and_return([mock_model(Room)])
      @cu.stub('up_to_date?').and_return false
    end

    it 'si une room est en retard affiche un flash' do
      @cu.stub(:status).and_return([:late_migration])
      get :index,{}, user_session
      flash[:alert].should == 'Une base au moins est en retard par rapport à la version de votre programme, migrer la base correspondante'
    end

    it 'si une room est en avance, affiche un flash' do
      @cu.stub(:status).and_return([:advance_migration])
      get :index,{}, user_session
      flash[:alert].should == 'Une base au moins est en avance par rapport à la version de votre programme, passer à la version adaptée'
    end

    it 'si une base n existe pas ' do
      @cu.stub(:status).and_return([:no_base])
      get :index,{}, user_session
      flash[:alert].should == 'Un fichier correspondant à une base n\'a pu être trouvée ; vous devriez effacer l\'enregistrement correspondant' 
    end

    end
  end

  

end
