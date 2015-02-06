# coding: utf-8

require 'spec_helper' 

RSpec.configure do |c| 
    # c.filter = {:wip=>true}
end

describe Compta::AnalyticalBalance do  
  include OrganismFixtureBis 


  before(:each) do
    use_test_organism    
  end
  
  describe 'with_default_values' do
    
    it 'remplit les valeurs from_date et to_date à partir de l argument' do
      cab = Compta::AnalyticalBalance.with_default_values(@p)
      cab.from_date.should == @p.start_date
      cab.to_date.should == @p.close_date 
    end
  end
  
  describe 'attributs de date' do 
    it 'les pickers permettent de remplir les champs from_date et to_date' do
      b = Compta::AnalyticalBalance.new
      b.from_date_picker =  '01/01/2012'
      b.from_date.should be_a(Date)
      b.from_date.should == Date.civil(2012,1,1)
      b.to_date_picker =  '01/01/2012'
      b.to_date.should be_a(Date)
      b.to_date.should == Date.civil(2012,1,1)
    end
  end
  
  describe 'validations' do
    
    subject {Compta::AnalyticalBalance.with_default_values(@p)}
    
    it 'une balance analytique avec default values est valide' do
      subject.should be_valid
    end
    
    it 'invalide sans period' do
      subject.period_id = nil
      subject.should_not be_valid
    end
    
    it 'invalide sans date de début' do
      subject.from_date = nil
      subject.should_not be_valid
    end
    
    it 'invalide sans period' do
      subject.to_date = nil
      subject.should_not be_valid
    end
    
    it 'invalide si une quelconque des dates n appartient pas à l exercice' do
      subject.to_date = (@p.close_date + 1)
      subject.should_not be_valid
    end
    
  end
  
  describe 'lines' do
    
    subject {Compta::AnalyticalBalance.with_default_values(@p)}
    
    it 'les lignes sont constituées de destinations et d une ligne sans activité' do
      subject.lines.should have(@o.destinations.size + 1).lignes  
    end
    
    it 'chaque destination doit recevoir ab_lines' do
      subject.destinations.each do |d|
        d.should_receive(:ab_lines)
      end
      subject.lines
    end
    
    it 'complété par un appel à orphan_lines' do
      subject.should_receive(:orphan_lines).exactly(3).times.and_return []
      subject.lines
    end
    
    it 'les lignes orphelines ont leur total' do
      subject.lines['Sans Activité'].should == 
        {:lines=>[], :sector_name=>"", :debit=>0, :credit=>0}
    end
    
    
  end
  
  context 'avec des écritures' do
    
    def ecriture(montant = 1, destination_id=nil, payment='Virement')
      @income_account = @p.accounts.classe_7.first
      ecriture = @ob.in_out_writings.new(
        {date:Date.today, 
          narration:'ligne créée par la méthode create_outcome_writing',
          :compta_lines_attributes=>{
            '0'=>{account_id:@income_account.id, destination_id:destination_id,
              nature:@n, debit:montant, payment_mode:payment},
            '1'=>{account_id:@baca.id, credit:montant, payment_mode:payment}
          }
        })
      puts ecriture.errors.messages unless ecriture.valid?
      ecriture.save
      ecriture
    end
    
    before(:each) do
      @dest = @o.destinations.second
      ecriture(45, @dest.id)
    end
        
    after(:each) do
      Writing.delete_all
      ComptaLine.delete_all
    end
    
    subject {Compta::AnalyticalBalance.with_default_values(@p)}
    
    it 'le total de la destination est conforme' do
      ls = subject.lines
      ls[@dest.name][:debit].should == 45
    end
    
    it 'le total des orphan_lines est conforme' do
      subject.lines['Sans Activité'][:credit].should == 45
    end
    
  end
  
  describe 'to_csv' do
    subject {Compta::AnalyticalBalance.with_default_values(@p)}
    
    before(:each) do
      subject.stub(:lines).and_return({'activité 1'=>{lines:[
              double(Account, number:'101', title:'Premier Compte', t_debit:'52.00', t_credit:'45.60'),
              double(Account, number:'206', title:'Deuxième Compte', t_debit:'16.12', t_credit:'0'),
              double(Account, number:'612', title:'Troisème Compte', t_debit:'0', t_credit:'16.20')
            ], debit:45, credit:23, sector_name:'Global'},
        'Sans activité'=>{lines:[
            double(Account, number:'101', title:'Premier Compte', t_debit:'52.00', t_credit:'45.60')
            ], debit:0, credit:0, sector_name:': aucun'}})
    end
    
    it 'repond à to_csv en renvoyant une String' do
      subject.to_csv.should be_a String
    end
    
    it 'avec 6 lignes ' do
      subject.to_csv.split("\n").should have(6).lines
    end
    
    it 'la première contient les titres' do
      subject.to_csv.split("\n").first.should ==  
        "Balance analytique\t\"\"\t\"\"\t\"\"\tDu 01/01/2015\tAu 31/12/2015"
    end
    
    it 'la première contient les titres' do
      subject.to_csv.split("\n").second.should ==  
        "Secteur\tActivité\tNuméro\tLibellé\tDébit\tCrédit"
    end
    
    it 'les autres affichent les valeurs par exemple' do
      subject.to_csv.split("\n").fourth.should ==
        "Global\tactivité 1\t206\tDeuxième Compte\t16.12\t0"
    end
    
    it 'repond à to_xls' do
      subject.to_xls
    end
    
  end
  
  
end