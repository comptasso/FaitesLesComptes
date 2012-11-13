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
        :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('201').id, debit:100 },
          '2'=>{account_id:Account.find_by_number('280').id, credit:5},
          '3'=>{account_id:Account.find_by_number('47').id, credit:95}
        }
      })
    @od.writings.create!({date:Date.today, narration:'ligne de terrain',
        :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('206').id, debit:1200 },
          '1'=>{account_id:Account.find_by_number('47').id, credit:1200}
        }
      })

    # création de deux rubriques
    @r1 = Compta::Rubrik.new(@p, 'Fonds commercial', :actif, '206 207 -290')
    @r2 = Compta::Rubrik.new(@p, 'Autres', :actif, '201 208 -280')
  end

  it 'vérif de @r1 et @r2' do
    @r1.totals.should == ['Total Fonds commercial', 1200.0, 0, 1200.0, 0.0]
    @r2.totals.should == ['Total Autres', 100.0, 5.0, 95.0, 0]
  end
  
  describe 'premier niveau' do
    before(:each) do
      @level1 = Compta::Rubriks.new(@p, 'Total 1', [@r1, @r2])
    end
    
    it 'brut' do
      @level1.brut.should == 1300.0
    end
    
    it 'amortissement' do
      @level1.amortissement.should == 5.0
    end
    
    it 'net' do
      @level1.net.should == 1295.0
    end

    it 'totals' do
      @level1.totals.should == ['Total 1', 1300.0, 5.0, 1295.0, 0]
    end

    describe 'second niveau' do

      before(:each) do
        @level1bis = Compta::Rubriks.new(@p, 'Total 1bis', [@r1])
        @level2 = Compta::Rubriks.new(@p, 'Niveau 2', [@level1, @level1bis])
      end

      it 'brut' do
        @level2.brut.should == 2500
      end

      it 'amortissement' do
        @level2.amortissement.should == 5.0
      end

      it 'net' do
        @level2.net.should == 2495.0
      end

      it 'totals' do
        @level2.totals.should == ['Niveau 2', 2500.0, 5.0, 2495.0, 0.0]
      end

      it 'lines' do
        @level2.lines.should == [['Total 1', 1300.0, 5.0, 1295.0, 0.0],
          ['Total 1bis', 1200.0, 0.0, 1200.0, 0]]
      end

    end
  end




end