# coding: utf-8 

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|   
  # c.filter = {:wip=>true}
end

describe Compta::Sheet do 
  include OrganismFixtureBis

  before(:each) do
    use_test_organism
    @folio = @o.nomenclature.actif
    
    
    w = @od.writings.new({date:Date.today, narration:'ligne pour controller rubrik',
        :compta_lines_attributes=>{
          '0'=>{account_id:@p.accounts.find_by_number('206').id, debit:100 },
          '1'=>{account_id:@p.accounts.find_by_number('201').id, debit:10},
          '2'=>{account_id:@p.accounts.find_by_number('2801').id, credit:5},
          '3'=>{account_id:@p.accounts.find_by_number('51201').id, credit:105}
        }
      })
    unless w.valid?
      puts w.errors.messages   
      puts w.narration
    end
    w.save!
    w = @od.writings.new({date:Date.today, narration:'ligne de terrain',
        :compta_lines_attributes=>{'0'=>{account_id:@p.accounts.find_by_number('201').id, debit:1200 },
          '1'=>{account_id:@p.accounts.find_by_number('51201').id, credit:1200}
        }
      })
    puts w.errors.messages + ' ' + w.narration unless w.valid?
    w.save!
  end
  
  #    after(:each) do
  #      Writing.delete_all
  #      ComptaLine.delete_all
  #    end

  it 'peut créer une instance' do 
    Compta::Sheet.new(@p, @folio ).should be_an_instance_of(Compta::Sheet) 
  end

  it 'sheet doit rendre un tableau' do  
    cs = Compta::Sheet.new(@p, @folio ).to_csv
    cs.should match "Bilan actif\nRubrique\tBrut\tAmort\tNet\tPrécédent\n"
    cs.should match "201 - Frais d'établissement\t1 210,00\t0,00\t1 210,00\t0,00\n"
    cs.should match "2801 - Amortissements des frais d'établissements\t0,00\t5,00\t-5,00\t0,00\n"
    cs.should match "Frais d'établissement\t1 210,00\t5,00\t1 205,00\t0,00"
    cs.should match "TOTAL ACTIF\t1 310,00\t5,00\t1 305,00\t0,00\n"
  end

  it 'si le sens n est pas actif, met certains champs à vide et inverse le signe' do
    
    cs = Compta::Sheet.new(@p, @o.nomenclature.passif).to_csv
    cs.should match "Bilan passif\nRubrique\tMontant\tPrécédent\n"
    cs.should match "102 - Fonds associatif sans droit de reprise\t0,00\t0,00\n"
  end

  it 'sheet peut créer le fichier csv pour l index' do
    #   Compta::RubrikLine.stub_chain(:new, :to_csv).and_return [CSV.generate {|c| c << ['101', 'Capital', 100,0,100,80]}]
    cs = Compta::Sheet.new(@p, @folio)
    cs.to_index_csv
  end

  it 'peut rendre un csv avec un sens passif' do
    cs = Compta::Sheet.new(@p, @o.nomenclature.passif)
    cs.to_index_csv
  end

  it 'sheet peut créer le fichier xls pour l index' do
    #   Compta::RubrikLine.stub_chain(:new, :to_csv).and_return [CSV.generate {|c| c << ['101', 'Capital', 100,0,100,80]}]
    cs = Compta::Sheet.new(@p, @folio)
    cs.to_index_xls
  end

  it 'peut rendre un pdf' do
    cs = Compta::Sheet.new(@p, @folio)
    cs.to_pdf.should be_an_instance_of Editions::Sheet
  end

  it 'fetch_lines demande à folio.root ses lines via fetch_lines' do
    cs = Compta::Sheet.new(@p, @folio)
    @folio.should_receive(:root).and_return(@rub = double(Rubrik))
    @rub.should_receive(:fetch_lines)
    cs.fetch_lines(@p)
  end
  
  it 'detailed lines est conforme' do
    fl = Compta::Sheet.new(@p, @folio).fetch_lines(@p).first
    fl.brut.should  == 1210.0
    fl.previous_net.should == 0.0
  end

  it 'peut rendre un detailed_pdf' do
    cs = Compta::Sheet.new(@p, @folio)
    cs.to_detailed_pdf.should be_an_instance_of Editions::DetailedSheet
  end

  it 'render pdf crée le pdf et le rend' do
    cs = Compta::Sheet.new(@p, @folio)
    cs.should_receive(:to_pdf).and_return(double Editions::Sheet, :render=>true)
    cs.render_pdf.should be_true
  end

  it 'sheet doit donner le total de ses lignes' do
    cs =  Compta::Sheet.new(@p, @folio)
    cs.folio.root.to_compta_rubrik(@p).totals.should == ['TOTAL ACTIF', 1310, 5.0, 1305 ,0 ]
     
  end
  
  describe 'avec 2 exercices'  do
    
    context 'dont le premier fermé', wip:true do
    
      before(:each) do
        @next_period = find_second_period
        @next_period.stub('previous_period_open?').and_return false
      end
    
      it 'csv prend en compte l exercice' do
        cs = Compta::Sheet.new(@next_period, @folio ).to_csv
        cs.should match "Bilan actif\nRubrique\tBrut\tAmort\tNet\tPrécédent\n"
        cs.should match "201 - Frais d'établissement\t0,00\t0,00\t0,00\t1 210,00\n"
      end
    
      it 'fetch_lines est conforme' do
        fl = Compta::Sheet.new(@next_period, @folio).fetch_lines(@next_period).first
        fl.brut.should  == 0.0
        fl.previous_net.should == 1210.0
      end
    
      it 'fetch_lines est conforme' do 
        fl = Compta::Sheet.new(@p, @folio).fetch_lines(@p).first
        fl.brut.should  == 1210.0
        fl.previous_net.should == 0.0
      end
    
    end
    
    context 'dont le premier ouvert' do
      
      before(:each) do
        @next_period = find_second_period
        @next_period.stub('previous_period_open?').and_return true
      end
      
      it 'prend en compte les reports pour les comptes de bilan' do
        fl = Compta::Sheet.new(@next_period, @folio).fetch_lines(@next_period).first
        fl.brut.should  == 1210.0
        fl.net.should == 1210 
        fl.previous_net.should == 1210.0
      end
      
      it 'mais pas pour les comptes de resultats' do
        folio = @o.nomenclature.resultat
        w = create_outcome_writing
        fls = Compta::Sheet.new(@next_period, folio).fetch_lines(@next_period)
        f = fls.select {|fl| fl.title == 'Achats mat premières et marchandises'}.first
        f.brut.should == 0 # le montant est à zéro, 
        f.previous_net.should == -99 # alors que pour l'ex précédent on a bien - 99
      end
      
    
      
    end
    
  end

end