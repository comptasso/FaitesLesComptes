require 'spec_helper'

RSpec.configure do |c|
  #  c.filter = {:wip=>true}
end



describe ImportedBelsController do
  include SpecControllerHelper  
  
  let(:ba) {stub_model(BankAccount, name: 'IBAN', number: '124578A', organism_id: @o.id)}
  
  before(:each) do
    minimal_instances
    BankAccount.stub(:find).and_return(ba) 
    
   
  end
  
  describe 'GET index' do  
    
    before(:each) do
      ba.stub_chain(:bank_extracts, :period, :unlocked).
        and_return([mock_model(BankExtract, begin_date:Date.today.beginning_of_month,
          end_date:Date.today.end_of_month)])
    end
    
    it 'recherche la banque' do
      BankAccount.should_receive(:find).with(ba.to_param).and_return ba   
      get :index,{bank_account_id: ba.to_param}, valid_session
    end
  end
  
  describe  'DELETE destroy' do 
    
    it 'trouve l ibel et le détruit' do
      BankAccount.should_receive(:find).with(ba.to_param).and_return ba 
      ImportedBel.should_receive(:find_by_id).with('3').and_return(@ibel = mock_model(ImportedBel))
      @ibel.should_receive(:destroy)
      delete :destroy, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
    end
      
    
  end
  
  describe 'POST write' do
    
    it 'cheche le ImportedBel' do 
      ImportedBel.should_receive(:find).with('3').and_return(@ibel = mock_model(ImportedBel))
      @ibel.stub(:write).and_return true
      post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
    end
    
    it 'écrit l\'écriture' do
      ImportedBel.stub(:find).with('3').and_return(@ibel = mock_model(ImportedBel))
      @ibel.should_receive(:write).and_return 126
      post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
    end
    
    it 'en cas de succès, affecte le numéro d écriture' do
      ImportedBel.stub(:find).with('3').and_return(@ibel = mock_model(ImportedBel))
      @ibel.stub(:write).and_return 126
      post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
      assigns(:writing_number).should == 126
    end 
    
    
  end
  
  
  
  
end
