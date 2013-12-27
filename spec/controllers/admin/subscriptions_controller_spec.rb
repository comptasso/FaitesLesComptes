# -*- encoding : utf-8 -*-

require 'spec_helper'

describe Admin::SubscriptionsController do
  include SpecControllerHelper
  
  let(:masks) {[mock_model(Mask, complete?:true), mock_model(Mask, complete?:false)]}
  
  before(:each) do
    minimal_instances
    sign_in(@cu)
    @o.stub(:subscriptions).and_return @a = double(Arel) 
    @o.stub_chain(:periods, :opened, :order, :first, :start_date, :year).and_return 2013
    @o.stub(:masks).and_return masks
  end
  
  describe "GET new" do
    before(:each) do
      @a.stub(:new).and_return mock_model(Subscription).as_new_record
    end
    
    it "assigns a new subscription as @subscription" do
      @a.should_receive(:new).and_return mock_model(Subscription).as_new_record
      get :new, {organism_id:@o.to_param}, valid_session
      assigns(:subscription).should be_a_new(Subscription)  
    end
    
    it 'rend le template new' do
      
      get :new, {organism_id:@o.to_param}, valid_session
      response.should render_template('new')
    end
    
    context 'pas de masque complet' do
      
      before(:each) do
        @o.stub(:masks).and_return [mock_model(Mask, complete?:false), mock_model(Mask, complete?:false)]
        request.env["HTTP_REFERER"] = 'origine'
      end
      
      it 'remplit un flash notice d avertissement' do
        get :new, {organism_id:@o.to_param}, valid_session
        flash[:notice].should == 'Vous n\'avez pas de guide de saisie permettant de générer une écriture périodique'
      end
      
      it 'redirige vers back' do
        get :new, {organism_id:@o.to_param}, valid_session
        response.should redirect_to 'origine'
      end
      
      
    end
  end
  
  describe 'POST create' do
    
    def valid_attributes
      {'title'=>'nouvel abonnement', 'day'=>'7', 'mask_id'=>'1'}
    end
    
    it 'crée un nouvel abonnement' do
      Subscription.should_receive(:new).with(valid_attributes).and_return(@sub = mock_model(Subscription).as_new_record)
      @sub.stub(:save).and_return true
      post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
    end
    
    it 'le sauve' do
      Subscription.stub(:new).and_return(@sub = mock_model(Subscription))
      @sub.should_receive(:save).and_return true 
      post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
    end
    
    context 'la sauvegarde est valide' do
      
      it 'redirige vers la vue index' do
        Subscription.stub(:new).and_return(@sub = mock_model(Subscription, save:true))
        post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
        response.should redirect_to admin_organism_subscriptions_url(@o)
      end
      
      it 'avec un flash' do
        Subscription.any_instance.stub(:save).and_return true
        post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
        flash[:notice].should == "L'écriture périodique 'nouvel abonnement' a été créée"
      end
    end
    
    context 'la sauvegarde est invalide' do
      
      it 'rend la vue new' do
        Subscription.stub(:new).and_return(@sub = mock_model(Subscription, save:false))
        post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
        response.should render_template('new')
      end
      
    end
    
  end
  
  
  
end