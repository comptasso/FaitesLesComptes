# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'spec_helper'

describe 'admin/bank_accounts/_form' do
  
  include JcCapybara
  
  let(:o) {mock_model(Organism)}
  
  before(:each) do
    assign(:organism, o )
    assign(:bank_account, mock_model(BankAccount))
  end
  
  context 'quand il n y a qu un secteur' do
    
    before(:each) {o.stub(:sectored?).and_return false}
  
    it 'cache le champ sector' do 
      render
      page.all('input#bank_account_sector_id.hidden').size.should == 1 
    end
  
  end
  
  context 'avec plusieurs secteurs' do
    before(:each) {o.stub(:sectored?).and_return true}
  
    it 'cache le champ sector' do 
      render
      page.all('input#bank_account_sector_id.hidden').size.should == 0 
    end
  end
  
end
