# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  c.filter = {wip:true}
end 
describe "Extract::Fec" do
  include OrganismFixtureBis
  
  before(:each) do
    create_organism
    @iow = create_in_out_writing
    @iow.lock
  end
      
  it 'un extract::fec a autant de lignes qu il y a de compta_lines'  do
    Extract::Fec.new(period_id:@p.id).lines.length.should == 2
  end
  
  it 'extract::fec extrait les lignes en joignant l écriture et le livre' do
    l = Extract::Fec.new(period_id:@p.id).lines.first
    l.book.title.should == 'Recettes'
    l.writing.date.should == Date.today
  end
  

  describe 'les différents champs'  do
    
    let(:line) { }
    
    before(:each) do
      @exfec = Extract::Fec.new(period_id:@p.id)
      @l = @exfec.lines.first
      @fec_line = @exfec.to_fec(@l)       
    end
    
    it 'sont conformes aux spéc du ministère' do
      @fec_line.should == 
        ['VE', # code journal 
        'Recettes', # Libellé journal
        @iow.continuous_id || '', # numéro sur une séquence continue de l'écriture comptable
        I18n::l(@iow.created_at.to_date), # date de comptabilisation de l'écriture
        @l.account.number, # numéro de compte
        @l.account.title, # libellé du compte
        '', # numéro de compte auxiliaire
        '', # libellé du compte auxiliaire
        '', # référence de la pièce justificative
        '', # date de la pièce justificative
        @iow.narration, # libellé de l'écriture comptable
        "99,00", "0,00", # montant débit et crédit
        '', '', # lettrage et date de lettrage
        I18n::l(@iow.updated_at.to_date), # date de comptabilisation (on utilise updated_at provisoirement
        # en attendant de rajouter un champ locked_at 
        '', '', #montant en devise et identifiant de la devise
        I18n::l(@iow.date), # date du règlement pour les compta de trésorerie
        @iow.payment_mode, # mode de règlement
        '' # nature de l'opération - est inutilisé
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
    
    
  end
end
