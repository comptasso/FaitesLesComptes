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
      :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('20').id, credit:100 },
        '1'=>{account_id:Account.find_by_number('201').id, credit:10},
        '2'=>{account_id:Account.find_by_number('280').id, debit:5},
        '3'=>{account_id:Account.find_by_number('47').id, debit:105},
      }
    })
  end

  it 'la rubrique a un titre' do
    @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles',  ['20', '201', '206', '207', '208', '-280'])
    @r.title.should == 'Immobilisations incorporelles' 
  end

  it 'la rubrique donne une liste de comptes avec leur solde' do
    @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles',  ['20', '201', '206', '207', '208', '-280'])
    @r.values.should == [
      ['20', 'Immobilisations incorporelles', 100.0, 0],
      ['201', 'Frais d\'établissement', 10.0, 0 ],
      ['206', 'Droit au bail', 0.0, 0 ],
      ['207', 'Fonds commercial', 0.0, 0 ],
      ['208', 'Autres immobilisations incorporelles', 0.0, 0 ],
      ['280', 'Amortissements des immobilisations incorporelles', 0, 5.0]
    ]
  end

  it 'doit gentiment ignorer un compte qui n\'existe pas' do
    @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles',  ['20', '201','205', '206', '207', '208', '-280'])
    @r.values.should == [
      ['20', 'Immobilisations incorporelles', 100.0, 0],
      ['201', 'Frais d\'établissement', 10.0, 0 ],
      ['206', 'Droit au bail', 0.0, 0 ],
      ['207', 'Fonds commercial', 0.0, 0 ],
      ['208', 'Autres immobilisations incorporelles', 0.0, 0 ],
      ['280', 'Amortissements des immobilisations incorporelles', 0, 5.0]
    ]
  end

  it 'intègre automatiquement les sous comptes', wip:true do
    @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles', ['20%'])
    @r.values.should == [
      ['20', 'Immobilisations incorporelles', 110.0, 0]
    ]
  end

  it 'renvoie la ligne de total' do
    @r = Compta::Rubrik.new(@p, 'Immobilisations incorporelles', ['20%', '-280'])
    @r.totals.should == ['Total Immobilisations incorporelles', 110.0, 5.0, 105.0]
  end

  

end
