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
    
    def writing_params
      {ref:'ref', compta_lines_attributes:{'0'=>
            {nature_id:1, destination_id:1, debit:10, credit:0},
        '1'=>{account_id:2, debit:0, credit:10}}}
    end
    
    before(:each) do
      @ibel = mock_model(ImportedBel, depense?:true, update_attribute:true) 
      ImportedBel.stub(:find).with('3').and_return(@ibel)
      @ibel.stub(:to_write).and_return(writing_params)
  
      ba.stub_chain(:sector, :outcome_book).and_return(@ob = mock_model(OutcomeBook))
      @ob.stub(:in_out_writings).and_return(@ar = double(Arel))
      @ar.stub(:new).and_return(@w = mock_model(Writing, 
           save:true))
      @controller.stub(:fill_author)
    end
    
    it 'cheche le ImportedBel' do 
      ImportedBel.should_receive(:find).with('3').and_return @ibel
      post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
    end
    
    it 'écrit l\'écriture' do
      @ibel.should_receive(:to_write).and_return writing_params
      post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
    end
    
    it 'en cas de succès, affecte le numéro d écriture' do
      
      post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
      assigns(:writing).should == @w
    end
    
    it 'en cas de succès, détruit l ibel' do
      @ibel.should_receive(:update_attribute).with(:writing_id, @w.id)
      post :write, {:bank_account_id=>ba.to_param,  :id => '3',format: :js}, valid_session
      
    end
    
    
  end
  
  
  
  
end
