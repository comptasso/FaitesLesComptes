# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 # c.filter = {:wip=>true}
end

describe Compta::RubrikResult do
  include OrganismFixtureBis

  context 'Avec des mocks' do

    before(:each) do
      @p = mock_model(Period, :resultat=>19, 'previous_period_open?'=>false)
      @p.stub(:accounts).and_return @ar = double(Arel)
      @ar.stub(:find_by_number).
        and_return(mock_model(Account, :sold_at=>51.25, sector_id:nil))
      @ar.stub(:where).with('number LIKE ? AND sector_id IS NOT NULL', '12%').and_return []
    end

    it 'si le compte n est pas sectorisé, donne juste sa valeur' do
      @rr = Compta::RubrikResult.new(@p, :passif, '1201')
      @rr.brut.should == 51.25 # le solde 51.25 sans résultat supplémentaire
      @rr.amortissement.should == 0
    end

    it 'mais rajoute le résultat sectorisé si le compte a un secteur' do
      @ar.stub(:find_by_number).
        and_return(mock_model(Account, :sold_at=>51.25, sector_id:1))
      @rr = Compta::RubrikResult.new(@p, :passif, '1201')
      @rr.brut.should == 70.25 # le solde 51.25 + 19 de resultat
      @rr.amortissement.should == 0
    end

    it 'pour un compte 12, donne le résultat' do
      @ar.stub(:find_by_number).
        and_return(mock_model(Account, :sold_at=>0, sector_id:1))
      @rr = Compta::RubrikResult.new(@p, :passif, '12')
      @rr.brut.should == 19 # le resultat
      @rr.amortissement.should == 0
    end

    it 'ne crée pas d erreur si pas de compte' do
      @ar.stub(:find_by_number).and_return(nil)
      @p.stub(:organism).and_return((mock_model(Organism, :title=>'Ma petite affaire')))
      @rr = Compta::RubrikResult.new(@p, :passif, '12')
      @rr.brut.should == 0
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

      it 'demande le résultat si un period précédent', wip:true do
        @q = mock_model(Period, 'previous_period_open?'=>false)
        @p.stub('previous_period?').and_return(true)
        @p.stub(:previous_period).and_return @q
        @p.stub(:previous_account).and_return(@pac = double(Account, :sold_at=>5, sector_id:1, number:'12'))
        @q.stub_chain(:accounts, :find_by_number).and_return(@pac)
        @q.stub(:resultat).and_return 22

        #Compta::RubrikResult.new(@q, :passif, '12').brut.should == 27
        Compta::RubrikResult.new(@p, :passif, '12').previous_net.should == 27
      end

    end
  end

  context 'avec plusieurs secteurs et des comptes de résultats par secteur'  do

    before(:each) do
      create_organism('Comité d\'entreprise')
      @asc = Sector.where('name = ?', 'ASC').first
      @acc_asc = @p.depenses_accounts(@asc.id).first
      @baca_asc = @asc.list_bank_accounts_with_communs(@p).first
      @b_asc = @asc.outcome_book
      @n_asc = @b_asc.natures.first

      @aep = Sector.where('name = ?', 'AEP').first
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
      cr = Compta::RubrikResult.new(@p, :passif, '1202')
      expect(cr.brut).to eq(-33.33)
    end

    it 'le résultat du compte 1202 est calculé' do
      cr = Compta::RubrikResult.new(@p, :passif, '1201')
      expect(cr.brut).to eq(-55)
    end

    it 'le résultat sectorisé ne doit pas être compté deux fois, même s il y 2 comptes (120x et 129x)', wip:true do
      cr = Compta::RubrikResult.new(@p, :passif, '12')
#      puts "premier total sectorisé : #{cr.total_resultat_sectorise}"
      expect(cr.total_resultat_sectorise).to eq(-88.33)
    end


    it 'le résultat du compte 12 ne reprend pas les autres', wip:true do
      cr = Compta::RubrikResult.new(@p, :passif, '12')
    #  puts "previous_net : #{cr.previous_net}"
    #  puts "total sectorisé : #{cr.total_resultat_sectorise}"
    #  puts "res sectorisé : #{cr.resultat_sectorise}"
    #  puts "res non sectorise : #{cr.resultat_non_sectorise}"
      expect(cr.brut).to eq 0
    end

  end

  context 'avec deux organisme et des secteurs' do

    before(:each) do
      use_test_organism('Comité d\'entreprise')
      @asc = Sector.where('name = ?', 'ASC').first
      @acc_asc = @p.depenses_accounts(@asc.id).first
      @baca_asc = @asc.list_bank_accounts_with_communs(@p).first
      @b_asc = @asc.outcome_book
      @n_asc = @b_asc.natures.first

      @aep = Sector.where('name = ?', 'AEP').first
      @acc_aep = @p.depenses_accounts(@aep.id).first
      @baca_aep = @aep.list_bank_accounts_with_communs(@p).first
      @b_aep = @aep.outcome_book
      @n_aep = @b_aep.natures.first

      create_writing(@b_asc, account_id:@acc_asc.id, nature_id:@n_asc.id,
      finance_account_id:@baca_asc.id)

      create_writing(@b_aep, montant:55, account_id:@acc_aep.id, nature_id:@n_aep.id,
      finance_account_id:@baca_aep.id)

      @q = find_second_period

    end

    it 'les résultats sont corrects' do
      expect(Compta::RubrikResult.new(@p, :passif, '1202').net).to eq(-33.33)
      expect(Compta::RubrikResult.new(@p, :passif, '1201').net).to eq(-55)
      expect(Compta::RubrikResult.new(@q, :passif, '1201').net).to eq(-55)
    end



  end

end


