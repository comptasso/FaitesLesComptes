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
    it 'recherche la banque' do
      BankAccount.should_receive(:find).with(ba.to_param).and_return ba   
      get :index,{bank_account_id: ba.to_param}, valid_session
    end
  end
  
  
  
  
end
