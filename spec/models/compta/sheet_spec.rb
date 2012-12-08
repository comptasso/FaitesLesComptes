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
      :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('206').id, credit:100 },
        '1'=>{account_id:Account.find_by_number('201').id, credit:10},
        '2'=>{account_id:Account.find_by_number('2801').id, debit:5},
        '3'=>{account_id:Account.find_by_number('47').id, debit:105}
      }
    })
  @od.writings.create!({date:Date.today, narration:'ligne de terrain',
      :compta_lines_attributes=>{'0'=>{account_id:Account.find_by_number('201').id, credit:1200 },
        '1'=>{account_id:Account.find_by_number('47').id, debit:1200}
      }
    })
  end

  it 'peut créer une instance' do
    Compta::Sheet.new(@p, list_rubriks, 'ACTIF' ).should be_an_instance_of(Compta::Sheet)
  end

  it 'sheet doit rendre un tableau' do
    
    cs = Compta::Sheet.new(@p, list_rubriks, 'ACTIF').to_csv

    cs.should match "Actif\nRubrique\tBrut\tAmort\tNet\tPrécédent\n"
    cs.should match "201 - Frais d'établissement\t-1 210,00\t0,00\t-1 210,00\t0,00\n"
    cs.should match "2801 - Amortissements des frais d'établissements\t0,00\t-5,00\t5,00\t0,00\n"
    cs.should match "Frais d'établissement\t-1 210,00\t-5,00\t-1 205,00\t0,00"
    cs.should match "TOTAL ACTIF\t-5,00\t-5,00\t0,00\t0,00\n"


  end

  it 'sheet doit donner le total de ses lignes' do
    pending
    Compta::Sheet.new(@p, 'test.yml', 'ACTIF IMMOBILISE - TOTAL 1').totals.should == [
      'ACTIF IMMOBILISE - TOTAL 1', 1310.0, 5.0, 1305.0
    ]
  end


end