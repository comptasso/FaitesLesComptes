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
      :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('20').id, credit:100 },
        '1'=>{account_id:Account.find_by_number('201').id, credit:10},
        '2'=>{account_id:Account.find_by_number('280').id, debit:5},
        '3'=>{account_id:Account.find_by_number('47').id, debit:105},
      }
    })
  end

  it 'sheet doit rendre un tableau' do
    Compta::Sheet.new(@p, 'test.yml').render.should == [
      ['Frais d\'établissement'],
      ['20', 'Immobilisations incorporelles', 110.0, 0],
      ['280', 'Amortissements des immobilisations incorporelles', 0, 5.0],
      ['Total Frais d\'établissement', 110.0, 5.0, 105.0],
      ['Terrains'],
      ['Total Terrains', 0, 0, 0] 

    ]
  end


end