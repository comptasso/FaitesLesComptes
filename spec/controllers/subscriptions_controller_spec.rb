require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe SubscriptionsController do
  include SpecControllerHelper
   
  before(:each) do
    minimal_instances
    #  sign_in(@cu)
    request.env["HTTP_REFERER"] = 'organism/1'
  end
  
  let(:sub) {mock_model(Subscription, late?:true, day:5, title:'Un abonnement')}
  
  describe 'POST index', wip:true do
    
    it 'récupère les subscriptions qui ont des écritures à passer' do
      Subscription.should_receive(:all).and_return([sub])
      get :index, {}, valid_session
    end
    
    it 'assigne les subscriptions' do
      Subscription.stub_chain(:all, :select).and_return([sub, sub])
      get :index, {}, valid_session
      assigns(:late_subscriptions).should == [sub, sub]
    end
    
    it 'et rend la vue index' do
      Subscription.stub_chain(:all, :select).and_return([sub])
      get :index, {}, valid_session
      response.should render_template('index')
    end
    
    it 'sans subscription en retard, rend un flash' do
      Subscription.stub_chain(:all, :select).and_return([])
      get :index, {}, valid_session
      flash[:notice].should == 'Pas d\'écriture à passer pour les abonnements existants'
    end
    
  end
   
  
  describe 'POST create' do
    
    it 'cherche la subscription' do
      Subscription.should_receive(:find).with('1').and_return nil     
      xhr :post, :create, { subscription:{id:'1'} }, valid_session
    end
    
    it 'si ne la trouve pas, crée un flash d erreur' do
      Subscription.stub(:find).with('1').and_return nil      
      xhr :post, :create, {subscription:{id:1}}, valid_session
      assigns[:error].should == 'Ecriture périodique non trouvée'
    end
    
    context 'la subscription existe' do
      
      before(:each) do 
        Subscription.stub(:find).with('1').and_return sub
        sub.stub(:month_year_to_write).and_return(@lms = ListMonths.new(Date.today << 3, Date.today))
      end  
        
    
      it 'mais n  est pas en retard' do
        sub.stub(:late?).and_return false
        xhr :post, :create, {subscription:{id:1}}, valid_session
        assigns[:error].should == "Ecriture périodique '#{sub.title}' n'a pas d'écritures à passer"
      end
    
      it 'passe les écritures pour chaque mois en retard' do
        sub.should_receive(:pass_writings)
        xhr :post, :create, {subscription:{id:1}}, valid_session
      end
    
      it 'et crée un flash notice' do
        sub.should_receive(:pass_writings).and_return 3
        xhr :post, :create, {subscription:{id:1}}, valid_session
        assigns[:notice].should == "3 écritures ont été générées par l'abonnement '#{sub.title}'"
      end
    
    end
  end 
  
  
  
end
