# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end


describe Compta::Sheet do 
include OrganismFixture

  before(:each) do
    create_minimal_organism
    @od.writings.create!({date:Date.today, narration:'ligne pour controller rubrik',
      :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('206').id, credit:100 },
        '1'=>{account_id:Account.find_by_number('201').id, credit:10},
        '2'=>{account_id:Account.find_by_number('280').id, debit:5},
        '3'=>{account_id:Account.find_by_number('47').id, debit:105}
      }
    })
  @od.writings.create!({date:Date.today, narration:'ligne de terrain',
      :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('201').id, credit:1200 },
        '1'=>{account_id:Account.find_by_number('47').id, debit:1200}
      }
    })
  end

  it 'sheet doit rendre un tableau' do
    pending
    Compta::Sheet.new(@p, 'test.yml', 'ACTIF IMMOBILISE - TOTAL 1').render.should == [
      ['Frais d\'établissement'],
      ['20', 'Immobilisations incorporelles', 110.0, 0],
      ['280', 'Amortissements des immobilisations incorporelles', 0, 5.0],
      ['Total Frais d\'établissement', 110.0, 5.0, 105.0],
      ['Immobilisations corporelles'],
      ['21', 'Immobilisations corporelles', 1200.0, 0],
      ['281', 'Amortissements des immobilisations corporelles', 0, -0.0],
      ['Total Immobilisations corporelles', 1200.0, 0, 1200.0]

    ]
  end

  it 'sheet doit donner le total de ses lignes' do
    pending
    Compta::Sheet.new(@p, 'test.yml', 'ACTIF IMMOBILISE - TOTAL 1').totals.should == [
      'ACTIF IMMOBILISE - TOTAL 1', 1310.0, 5.0, 1305.0
    ]
  end


end