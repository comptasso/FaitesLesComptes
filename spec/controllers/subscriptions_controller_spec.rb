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
   
  
  describe 'POST create' do
    
    it 'cherche la subscription' do
      Subscription.should_receive(:find).with('1').and_return nil     
      post :create, {subscription:{id:1}}, valid_session
    end
    
    it 'si ne la trouve pas, crée un flash d erreur' do
      Subscription.stub(:find).with('1').and_return nil      
      post :create, {subscription:{id:1}}, valid_session
      flash[:alert].should == 'Ecriture périodique non trouvée'
    end
    
    context 'la subscription existe' do
      
      before(:each) do 
        Subscription.stub(:find).with('1').and_return sub
        sub.stub(:month_year_to_write).and_return(@lms = ListMonths.new(Date.today << 3, Date.today))
      end  
        
    
    it 'mais n  est pas en retard' do
      sub.stub(:late?).and_return false
      post :create, {subscription:{id:1}}, valid_session
      flash[:alert].should == "Ecriture périodique '#{sub.title}' n'a pas d'écritures à passer"
    end
    
    it 'passe les écritures pour chaque mois en retard' do
      Utilities::Writer.should_receive(:new).with(sub).and_return(@uw = double(Utilities::Writer))
      @uw.should_receive(:write).exactly(@lms.size).and_return true
      post :create, {subscription:{id:1}}, valid_session
    end
    
      it 'et crée un flash notice' do
        Utilities::Writer.stub(:new).with(sub).and_return(@uw = double(Utilities::Writer))
      @uw.stub(:write).and_return true
      post :create, {subscription:{id:1}}, valid_session
      flash[:notice].should == "4 écritures ont été générées pas l'écriture périodique #{sub.title}"
      end
    
  end
  end 
  
  
  
end
