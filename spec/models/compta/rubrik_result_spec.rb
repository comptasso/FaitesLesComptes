# coding: utf-8

require 'spec_helper'

RSpec.configure do |c| 
 #   c.filter = {:wip=>true}
end

describe Compta::RubrikResult do
  include OrganismFixtureBis
  
  context 'Avec des mocks', wip:true do

    before(:each) do
      @p = mock_model(Period, :resultat=>19, :previous_period=>nil)
      @p.stub(:accounts).and_return @ar = double(Arel)
      @ar.stub(:find_by_number).
        and_return(mock_model(Account, :sold_at=>51.25, sector_id:nil))
      @ar.stub(:where).with('number LIKE ? AND sector_id IS NOT NULL', '12%').and_return []
    end

    it 'se crée avec un exercice' do
      Compta::RubrikResult.new(@p, :passif, '12').should be_an_instance_of(Compta::RubrikResult)
    end

    it 'initialise ses valeurs' do
      @rr = Compta::RubrikResult.new(@p, :passif, '12')
      @rr.brut.should == 70.25  # le solde 51.25 plus le résultat : 19)
      @rr.amortissement.should == 0
    end

    it 'ne crée pas d erreur si pas de compte' do
      @ar.stub(:find_by_number).and_return(nil)
      @p.stub(:organism).and_return((mock_model(Organism, :title=>'Ma petite affaire')))
      @rr = Compta::RubrikResult.new(@p, :passif, '12')
      @rr.brut.should == 19
      @rr.amortissement.should == 0
    end

    describe 'previous_net' do

      before(:each) do
        @rr = Compta::RubrikResult.new(@p, :passif, '12')
      end

      it 'previous net renvoie 0 si pas de previous_period' do
        @p.stub('previous_period?').and_return false
        @rr.previous_net.should == 0
      end

      it 'demande le résultat si un period précédent' do
        @p.stub('previous_period?').and_return true
        @p.stub(:organism).and_return((mock_model(Organism, :title=>'Ma petite affaire')))
        @q = mock_model(Period)
        @q.stub(:organism) {mock_model(Organism, :title=>'Ma petite affaire')}
        @p.should_receive(:previous_period).and_return(@q)
        @q.stub_chain(:accounts, :find_by_number).
          and_return(double(Account, :sold_at=>5, sector_id:1, number:'12'))
        @q.should_receive(:resultat).and_return 22
        @rr.previous_net.should == 27
      end

    end
  end
  
  context 'avec plusieurs secteurs et des comptes de résultats par secteur' do
    
    before(:each) do
      create_organism('Comité d\'entreprise')
      @asc = Sector.where('name = ?', 'ASC').first
      @acc_asc = @p.depenses_accounts(@asc.id).first
      @baca_asc = @asc.list_bank_accounts_with_communs(@p).first
      @b_asc = @asc.outcome_book
      @n_asc = @b_asc.natures.first
      
      @aep = Sector.where('name = ?', 'Fonctionnement').first
      @acc_aep = @p.depenses_accounts(@aep.id).first
      @baca_aep = @aep.list_bank_accounts_with_communs(@p).first
      @b_aep = @aep.outcome_book
      @n_aep = @b_aep.natures.first
      
      create_writing(@b_asc, account_id:@acc_asc.id, nature_id:@n_asc.id, 
      finance_account_id:@baca_asc.id)
    
      create_writing(@b_aep, montant:55, account_id:@acc_aep.id, nature_id:@n_aep.id, 
      finance_account_id:@baca_aep.id)
      
    end
    
    after(:each) do
      clean_organism
    end
    
    it 'le résultat du compte 1201 est calculé' do
      cr = Compta::RubrikResult.new(@p, :passif, '1201')
      expect(cr.net).to eq -33.33 
    end
    
    it 'le résultat du compte 1202 est calculé' do
      cr = Compta::RubrikResult.new(@p, :passif, '1202')
      expect(cr.net).to eq -55
    end
    
    it 'le résultat du compte 12 ne reprend pas les autres' do
      cr = Compta::RubrikResult.new(@p, :passif, '12')
      expect(cr.net).to eq 0 
    end
    
    
    
    
    
    
    
    
  end

end


