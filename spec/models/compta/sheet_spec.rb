# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end


describe Compta::Sheet do 
include OrganismFixture

  def list_rubriks
      {:title=>"BILAN ACTIF", :sens=>:actif,
        :rubriks=>{:"TOTAL ACTIF"=>{:IMMOBILISATIONS=>{:"Immobilisations incorporelles"=>{:"Frais d'établissement"=>"201 -2801",
                :"Frais de recherche et développement"=>"203 -2803",
                :"Fonds commercial'"=>"206 207 -2807 -2906 -2907", :Autres=>"208 -2808 -2809"},
              :"Immobilisations corporelles"=>{:Agencements=>"212 -2812 -2912",
                :"Installations techniques, matériel et outillage"=>"215 -2815 -2915",
                :Autres=>"218 -2818",
                :"Immobilisations corporelles en cours"=>"23 -293"},
              :"Immobilisations financières"=>{:"Immobilisations financières"=>"27 -297"}},
            :"ACTIF CIRCULANT"=>{:"Stocks et encours"=>{:Marchandises=>"37 -397"},
              :Créances=>{:"Avances et acomptes versés sur commandes"=>"4091",
                :"Créances usagers et comptes rattachés"=>"41 !419 -491 -492",
                :Autres=>"409 !4091 43D 44D 45D 46D 47D -495 -496"}},
            :"DISPONIBILITES ET AUTRES"=>{:Disponibilités=>{:"Autres titres"=>"50 -590",
                :Banques=>"51D", :Disponibilités=>"53"},
              :"Autres actifs"=>{:"Charges constatées d'avance"=>"486",
                :"Charges à répartir sur plusiseurs exercices"=>"481"}}}}}

  end



  before(:each) do
    create_minimal_organism
    @od.writings.create!({date:Date.today, narration:'ligne pour controller rubrik',
      :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('206').id, debit:100 },
        '1'=>{account_id:Account.find_by_number('201').id, debit:10},
        '2'=>{account_id:Account.find_by_number('2801').id, credit:5},
        '3'=>{account_id:Account.find_by_number('51').id, credit:105}
      }
    })
  @od.writings.create!({date:Date.today, narration:'ligne de terrain',
      :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('201').id, debit:1200 },
        '1'=>{account_id:Account.find_by_number('51').id, credit:1200}
      }
    })
  end

  it 'peut créer une instance' do
    Compta::Sheet.new(@p, list_rubriks, 'ACTIF' ).should be_an_instance_of(Compta::Sheet)
  end

  it 'sheet doit rendre un tableau' do
    cs = Compta::Sheet.new(@p, list_rubriks, 'ACTIF').to_csv
    cs.should match "Actif\nRubrique\tBrut\tAmort\tNet\tPrécédent\n"
    cs.should match "201 - Frais d'établissement\t1 210,00\t0,00\t1 210,00\t0,00\n"
    cs.should match "2801 - Amortissements des frais d'établissements\t0,00\t5,00\t-5,00\t0,00\n"
    cs.should match "Frais d'établissement\t1 210,00\t5,00\t1 205,00\t0,00"
    cs.should match "TOTAL ACTIF\t1 310,00\t5,00\t1 305,00\t0,00\n"
  end

  it 'si le sens n est pas actif, met certains champs à vide et inverse le signe' do
    lr = list_rubriks
    lr[:sens] = :passif
    cs = Compta::Sheet.new(@p, lr, 'PASSIF').to_csv
    cs.should match "Passif\nRubrique\tMontant\tPrécédent\n"
    cs.should match "201 - Frais d'établissement\t-1 210,00\t0,00\n"
  end

  it 'sheet peut créer le fichier csv pour l index' do
 #   Compta::RubrikLine.stub_chain(:new, :to_csv).and_return [CSV.generate {|c| c << ['101', 'Capital', 100,0,100,80]}]
    cs = Compta::Sheet.new(@p, list_rubriks, 'ACTIF')
    cs.to_index_csv
  end

  it 'sheet peut créer le fichier xls pour l index' do
 #   Compta::RubrikLine.stub_chain(:new, :to_csv).and_return [CSV.generate {|c| c << ['101', 'Capital', 100,0,100,80]}]
    cs = Compta::Sheet.new(@p, list_rubriks, 'ACTIF')
    cs.to_index_xls
  end

  it 'peut rendre un pdf' do
    cs = Compta::Sheet.new(@p, list_rubriks, 'ACTIF')
    cs.to_pdf.should be_an_instance_of PdfDocument::PdfSheet
  end

  it 'peut rendre un detailed_pdf' do
    cs = Compta::Sheet.new(@p, list_rubriks, 'ACTIF')
    cs.to_detailed_pdf.should be_an_instance_of PdfDocument::PdfDetailedSheet
  end

  it 'render pdf crée le pdf et le rend' do
    cs = Compta::Sheet.new(@p, list_rubriks, 'ACTIF')
    cs.should_receive(:to_pdf).and_return(double PdfDocument::PdfSheet, :render=>true)
    cs.render_pdf.should be_true
  end

  it 'sheet doit donner le total de ses lignes' do
    cs =  Compta::Sheet.new(@p, list_rubriks, 'ACTIF')
    cs.datas.totals.should == ['TOTAL ACTIF', 1310, 5.0, 1305 ,0 ]
     
  end


end