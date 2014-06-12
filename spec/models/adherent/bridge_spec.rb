require 'spec_helper'

RSpec.configure do |c|
 # c.filter = {wip:true}
end

describe Adherent::Bridge do 
  include OrganismFixtureBis 
  
  before(:each) do
    use_test_organism    
    @bridge= @o.bridge
  end
  
  it 'bridge est une instance de Adherent::Bridge' do 
    @bridge.should be_an_instance_of(Adherent::Bridge) 
  end
  
  describe 'check_nature_name' , wip:true do 
    
    before(:each) do
      @p2 = find_second_period 
    end
    
    it 'renvoie true si la nature existe pour toutes les périodes ouvertes' do
      @bridge.check_nature_name.should be_true
    end
    
    it 'et faux sinon' do
      @p2.natures.find_by_name('Cotisations des adhérents').delete
      @bridge.check_nature_name.should be_false
    end
    
  end
  
  
  
  describe 'payment_values' do
    it 'appelle les fonctions nécessaires' do
      
    end
    
    describe 'retourne les bonnes valeurs'  do
      
      before(:each) do
        @vals = @bridge.payment_values(@p)
      end  
      
      
      
      it 'bank_account_account_id est rempli' do
        @vals[:bank_account_account_id].should_not be_nil
        acc = Account.find(@vals[:bank_account_account_id])
        acc.period.should == @p
        @o.bank_accounts.should include(acc.accountable) 
      end
      
      it 'cash_id est rempli' do
        @vals[:cash_account_id].should_not be_nil
        acc = Account.find(@vals[:cash_account_id])
        acc.period.should == @p
        @o.cashes.should include(acc.accountable) 
      end 
     
      
      it 'nature_id est rempli'do
        @vals[:nature_id].should == @p.natures.find_by_name(@bridge.nature_name).id
        @vals[:nature_id].should_not be_nil
      end
      
      
      
      
    
    end
  end
end
