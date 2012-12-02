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
    
    Compta::Sheet.new(@p, list_rubriks, 'ACTIF').to_csv.should ==
      %Q(Actif
Rubrique\tBrut\tAmort\tNet\tPrécédent
Frais d'établissement\t-1210,0\t-5,0\t-1205,0\t0,0
Frais de recherche et développement\t0\t0,0\t0,0\t0,0
Fonds commercial'\t-100,0\t0,0\t-100,0\t0,0
Autres\t-0,0\t0\t-0,0\t0,0
Immobilisations incorporelles\t-1310,0\t-5,0\t-1305,0\t0,0
Agencements\t0,0\t0,0\t0,0\t0,0
Installations techniques, matériel et outillage\t0,0\t0,0\t0,0\t0,0
Autres\t-0,0\t0\t-0,0\t0,0
Immobilisations corporelles en cours\t-0,0\t0\t-0,0\t0,0
Immobilisations corporelles\t0,0\t0,0\t0,0\t0,0
Immobilisations financières\t0,0\t0,0\t0,0\t0,0
Immobilisations financières\t0,0\t0,0\t0,0\t0,0
IMMOBILISATIONS\t-1310,0\t-5,0\t-1305,0\t0,0
Marchandises\t0,0\t0,0\t0,0\t0,0
Stocks et encours\t0,0\t0,0\t0,0\t0,0
Avances et acomptes versés sur commandes\t0\t0\t0\t0
Créances usagers et comptes rattachés\t0,0\t0,0\t0,0\t0,0
Autres\t1305,0\t0,0\t1305,0\t0,0
Créances\t1305,0\t0,0\t1305,0\t0,0
ACTIF CIRCULANT\t1305,0\t0,0\t1305,0\t0,0
Autres titres\t0,0\t0,0\t0,0\t0,0
Banques\t-0,0\t0\t-0,0\t0,0
Disponibilités\t-0,0\t0\t-0,0\t0,0
Disponibilités\t0,0\t0,0\t0,0\t0,0
Charges constatées d'avance\t-0,0\t0\t-0,0\t0,0
Charges à répartir sur plusiseurs exercices\t-0,0\t0\t-0,0\t0,0
Autres actifs\t-0,0\t0\t-0,0\t0,0
DISPONIBILITES ET AUTRES\t0,0\t0,0\t0,0\t0,0
TOTAL ACTIF\t-5,0\t-5,0\t0,0\t0,0
BILAN ACTIF\t-5,0\t-5,0\t0,0\t0,0\n)
  end

  it 'sheet doit donner le total de ses lignes' do
    pending
    Compta::Sheet.new(@p, 'test.yml', 'ACTIF IMMOBILISE - TOTAL 1').totals.should == [
      'ACTIF IMMOBILISE - TOTAL 1', 1310.0, 5.0, 1305.0
    ]
  end


end