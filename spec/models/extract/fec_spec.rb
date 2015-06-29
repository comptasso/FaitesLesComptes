# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 # c.filter = {wip:true} 
end 
describe Extract::Fec do
  include OrganismFixtureBis
  
  before(:each) do
    use_test_organism
    @iow = create_in_out_writing(10001.35)
    @iow.lock
  end
  
  after(:each) do
    Writing.delete_all
    ComptaLine.delete_all
  end
  
  it 'un extract::fec a autant de lignes qu il y a de compta_lines'  do
    Extract::Fec.new(period_id:@p.id).lines.length.should == ComptaLine.count
  end
  
  it 'extract::fec extrait les lignes en joignant l écriture et le livre' do
    l = Extract::Fec.new(period_id:@p.id).lines.first
    l.book.title.should == 'Recettes'
    l.writing.date.should == Date.today
  end
  

  describe 'les différents champs'  do
    
    
    
    before(:each) do
      @exfec = Extract::Fec.new(period_id:@p.id)
      @l = @exfec.lines.first
      @fec_line = @exfec.to_fec(@l)       
    end
    
    it 'le numéro de compte est complété par des zéros pour avoir au moins 3 chiffres' do
      @l.stub(:account).and_return(double(number:'60', title:'Le compte'))
      fec_line = @exfec.to_fec(@l)
      fec_line[4].should == '600'
    end
    
    it 'sont conformes aux spéc du ministère' do
      
      @fec_line.should == 
        ['VE', # code journal 
        'Recettes', # Libellé journal
        @iow.continuous_id || '', # numéro sur une séquence continue de l'écriture comptable
        Date.today.strftime('%Y%m%d'), # date de comptabilisation de l'écriture
        @l.account.number, # numéro de compte
        @l.account.title, # libellé du compte
        '', # numéro de compte auxiliaire
        '', # libellé du compte auxiliaire
        '', # référence de la pièce justificative
        # TODO à modifier lorsque le champ ref_date sera utilisé.
        @iow.date.strftime('%Y%m%d'), # date de la pièce justificative
        @iow.narration, # libellé de l'écriture comptable
        ActionController::Base.helpers.number_with_precision(@l.debit, precision:2, delimiter:''), # montant débit
        ActionController::Base.helpers.number_with_precision(@l.credit, precision:2, delimiter:''), # montant débit
        '', nil, # lettrage et date de lettrage
        @iow.locked_at.to_date.strftime('%Y%m%d'), # date de comptabilisation 
        # en attendant de rajouter un champ locked_at 
        nil, '', #montant en devise et identifiant de la devise
        @iow.date.strftime('%Y%m%d'), # date du règlement pour les compta de trésorerie
        @iow.payment_mode, # mode de règlement
        '', # nature de l'opération - est inutilisé
        ''
        ]
    end
  end
  
  describe 'to_csv' do
    
    before(:each) { @exfec = Extract::Fec.new(period_id:@p.id) }
    
    it 'fournit ici un fichier de 3 lignes' do
      @exfec.to_csv.should have(3).lines
    end
    
    it 'première ligne de titre est conforme aux spéc du ministère' do
      @exfec.to_csv.lines.first.should == Extract::Fec::FEC_TITLES.join("\t") + "\n"
    end
    
    it 'les autres lignes font appel à to_fec' , wip:true do
      @exfec.should_receive(:to_fec).exactly(2).times.and_return(['bonjour'])
      @exfec.to_csv
    end
    
    it 'le titre du FEC est conforme' do
      # d = Date.today.end_of_year.strftime()
      @exfec.fec_title.should == '123456789FEC20151231.csv'
    end
    
    
  end
  
  
end


#  FEC_TITLES = [  # selon la nomenclature de l'arrêté du 29 juillet 2013 
#    'JournalCode',  
#    'JournalLib',  #champ 2
#    'EcritureNum',
#    'EcritureDate',
#    'CompteNum',
#    'CompteLib',
#    'CompAuxNum',
#    'CompAuxLib',
#    'PieceRef',
#    'PieceDate',
#		'EcritureLib',
#    'Debit',
#    'Credit',
#    'EcritureLet',
#    'DateLet',
#    'ValidDate', # champ 15
#    'Montantdevise',
#    'Idevise',
#    'DateRglt', 
#    'ModeRglt',
#    'NatOp', 
#    'IdClient']