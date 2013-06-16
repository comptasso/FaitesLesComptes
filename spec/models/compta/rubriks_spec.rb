# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end


describe Compta::Sheet do
  include OrganismFixtureBis

  before(:each) do
    create_minimal_organism
    @od.writings.create!({date:Date.today, narration:'ligne pour controller rubrik',
        :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('201').id, debit:100 },
          '2'=>{account_id:Account.find_by_number('2801').id, credit:5},
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
    @r2 = Compta::Rubrik.new(@p, 'Autres', :actif, '201 208 -2801')
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

    it 'total_actif' do
      @level1.total_actif.should == ['Total 1', 1300.0, 5.0, 1295.0, 0]
    end

    it 'total_passif' do
      @level1.total_passif.should == ['Total 1', 1295.0, 0]
    end

    it 'sa prfondeur est de  1' do
      @level1.depth.should == 1
    end

    it 'fetch_lines renvoie le détail des lignes et des Rubrik'  do
      fl = @level1.fetch_lines
      fl.should have(8).elements
      fl[0].to_actif.should == ['206 - Droit au bail', 1200.00, 0, 1200.0, 0]
      fl[1].to_actif.should == ['2906 - Dépréciations des immobilisations incorporelles', 0, 0, 0, 0]
      fl[2].totals.should == ['Fonds commercial', 1200, 0, 1200, 0]
      fl[3].to_actif.should == ['201 - Frais d\'établissement', 100, 0, 100, 0]
      fl[4].to_actif.should == ['208 - Autres immobilisations incorporelles', 0, 0, 0, 0]
      fl[5].to_actif.should == ['2801 - Amortissements des frais d\'établissements', 0, 5, -5, 0]
      fl[6].totals.should == ['Autres', 100, 5, 95, 0]
      fl[7].totals.should == ['Total 1', 1300, 5, 1295, 0]
    end
    
    
    it 'to_pdf' , wip:true do
      @level1.to_pdf.should be_an_instance_of(PdfDocument::PdfRubriks)
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

      it 'sa prfondeur est de 2' do
        @level2.depth.should == 2
      end

      it 'peut lister ses rubriks' do
        @level2.fetch_rubriks.collect {|rs| rs.title }.should == [ 'Total 1', 'Total 1bis', 'Niveau 2']
      end

      it 'peut lister ses rubriks et sous rubriques' do
        @level2.fetch_rubriks_with_rubrik.collect {|rs| rs.title }.should == ['Fonds commercial',
          'Autres', 'Total 1', 'Fonds commercial', 'Total 1bis', 'Niveau 2']
      end

    end
  end




end