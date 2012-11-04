# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
 # c.filter = {:wip=>true}
end


describe Compta::Listing do
  include OrganismFixture

  before(:each) do
    create_minimal_organism
    @od.writings.create!({date:Date.today, narration:'ligne pour controller rubrik',
        :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('20').id, debit:100 },
          '1'=>{account_id:Account.find_by_number('201').id, debit:10},
          '2'=>{account_id:Account.find_by_number('280').id, credit:5},
          '3'=>{account_id:Account.find_by_number('47').id, credit:105},
        }
      })
  end

  it 'la rubrique a un titre' do
    @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles', :actif,  ['20', '201', '206', '207', '208', '-280'])
    @r.title.should == 'Immobilisations incorporelles' 
  end

  it 'la rubrique donne une liste de comptes avec leur solde' do
    @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles',  :actif, ['20', '201', '206', '207', '208', '-280'])
    @r.lines.should == [
      ['20', 'Immobilisations incorporelles', 100.0, 0],
      ['201', 'Frais d\'établissement', 10.0, 0 ],
      ['206', 'Droit au bail', 0.0, 0 ],
      ['207', 'Fonds commercial', 0.0, 0 ],
      ['208', 'Autres immobilisations incorporelles', 0.0, 0 ],
      ['280', 'Amortissements des immobilisations incorporelles', 0, 5.0]
    ]
  end

  it 'doit gentiment ignorer un compte qui n\'existe pas' do
    @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles', :actif,  ['20', '201','205', '206', '207', '208', '-280'])
    @r.lines.should == [
      ['20', 'Immobilisations incorporelles', 100.0, 0],
      ['201', 'Frais d\'établissement', 10.0, 0 ],
      ['206', 'Droit au bail', 0.0, 0 ],
      ['207', 'Fonds commercial', 0.0, 0 ],
      ['208', 'Autres immobilisations incorporelles', 0.0, 0 ],
      ['280', 'Amortissements des immobilisations incorporelles', 0, 5.0]
    ]
  end

  it 'intègre automatiquement les sous comptes', wip:true do
    @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles', :actif, ['20%'])
    @r.lines.should == [
      ['20', 'Immobilisations incorporelles', 110.0, 0]
    ]
  end

  it 'renvoie la ligne de total' do
    @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles', :actif, ['20%', '-280'])
    @r.totals.should == ['Immobilisations incorporelles', 110.0, 5.0, 105.0]
  end
  
  it 'doit gérér les -28%'

  describe 'valeurs' do
  
    before(:each) do
      @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles',  :actif, ['20', '201','205', '206', '207', '208', '-280'])
    end

    it 'brut' do
      @r.brut.should == 110.0
    end

    it 'amortissement' do
      @r.amortissement.should == 5.0
    end

    it 'alias depreciation' do
      @r.depreciation.should == 5.0
    end

    it 'net' do
      @r.net.should == 105.0
    end

    it 'previous_net égale zero si pas d exercice précédent'  do
      @p.stub(:previous_period?).and_return false
      @r.previous_net.should == 0.0
    end

    it 'previous net revoie la valeur demandée pour l exercice précedent', wip:true do
      @p.should_receive(:previous_period?).and_return true
      @p.should_receive(:previous_period).and_return @p2 = mock_model(Period)
      Compta::Rubrik.should_receive(:new).with(@p2,'Immobilisations incorporelles',  :actif, ['20', '201','205', '206', '207', '208', '-280'] ).and_return cr = double(Compta::Rubrik)
      cr.should_receive(:net).and_return 999
      @r.previous_net.should == 999
    end

  end

end
