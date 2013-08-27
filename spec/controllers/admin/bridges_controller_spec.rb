require 'spec_helper'

describe Admin::BridgesController do
  include SpecControllerHelper
    
  before(:each) do
    minimal_instances
    sign_in(@cu)
    
  end
  
  
  describe "GET 'show'" do 
    it "returns http success" do
      @o.stub(:bridge).and_return 'bonjour'
      get :show, {:organism_id=>@o.id.to_s}, valid_session
      response.should be_success
    end
    
    it 'assigns bridge' do
      @o.stub(:bridge).and_return 'bonjour'
      get :show, {:organism_id=>@o.id.to_s}, valid_session
      assigns[:bridge].should == 'bonjour'
    end
  end
  
  describe "GET edit" do 
    
    before(:each) do
      @o.stub(:bridge).and_return(@bridge = mock_model(Adherent::Bridge))
      get :edit, {:organism_id=>@o.id.to_s, :id=>@bridge.to_param}, valid_session
    end
    
    it 'return http success' do
      response.should be_success
    end
    
    it 'assigns @bridge' do
      assigns[:bridge].should == @bridge
    end
    
    it 'rend la vue edit' do
      response.should render_template 'edit'
    end
    
  end
  
  describe 'POST update' do
    
    before(:each) do
      @parametres = {'nature_name'=>'une autre', 'destination_id'=>'3'} 
      @o.stub(:bridge).and_return(@bridge = mock_model(Adherent::Bridge))
      
    end
    
    describe 'cas du succès' do
      it 'doit être mis à jour' do
        @bridge.stub(:check_nature_name).and_return true
        @bridge.should_receive(:update_attributes).with(@parametres).and_return true
        post :update, {:organism_id=>@o.id.to_s, :id=>@bridge.to_param, :bridge=>@parametres}, valid_session
        response.should redirect_to admin_organism_bridge_url(@o)
      end
      
      it 'envoie un flash notice' do
        @bridge.stub(:check_nature_name).and_return true
        @bridge.stub(:update_attributes).with(@parametres).and_return true
        post :update, {:organism_id=>@o.id.to_s, :id=>@bridge.to_param, :bridge=>@parametres}, valid_session
        flash[:notice].should == 'Les paramètres ont été modifiés'
      end
      
      describe 'vérifie que le nature_name existe pour tous les exercices ouverts'
      
      it 'si oui' do
        @bridge.stub(:check_nature_name).and_return true
        @bridge.stub(:update_attributes).with(@parametres).and_return true
        post :update, {:organism_id=>@o.id.to_s, :id=>@bridge.to_param, :bridge=>@parametres}, valid_session
        flash[:notice].should == 'Les paramètres ont été modifiés'
        flash[:alert].should == nil
      end
      
      it 'si non' do
        @bridge.stub(:check_nature_name).and_return false
        @bridge.stub(:update_attributes).with(@parametres).and_return true
        post :update, {:organism_id=>@o.id.to_s, :id=>@bridge.to_param, :bridge=>@parametres}, valid_session
        flash[:notice].should == 'Les paramètres ont été modifiés'
        flash[:alert].should_not == nil
      end
      
    end
    
    describe 'en cas d echec' do
      
      it 'réaffiche edit' do
        @bridge.stub(:update_attributes).with(@parametres).and_return false
        post :update, {:organism_id=>@o.id.to_s, :id=>@bridge.to_param, :bridge=>@parametres}, valid_session
        response.should render_template 'edit'
      end
      
      it 'avec un flash d alerte' do
        @bridge.stub(:update_attributes).with(@parametres).and_return false
        post :update, {:organism_id=>@o.id.to_s, :id=>@bridge.to_param, :bridge=>@parametres}, valid_session
        flash[:alert].should == 'Impossible d\'enregistrer les paramètres'
      end
      
    end
    
    
    
  end

end
