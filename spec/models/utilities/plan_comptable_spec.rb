# coding: utf-8

require 'spec_helper'
require 'utilities/plan_comptable'

 # TODO compléter les spec de cette classe

describe Utilities::PlanComptable do 
  
  before(:each) do
    Account.any_instance.stub(:sectorise_for_67).and_return true
  end

  let(:o) {double(Organism, sectored?:false, database_name:SCHEMA_TEST)}  

  describe 'self.create_accounts' do
    
    before(:each) do  
      
      @p = Period.new(start_date:Date.today.beginning_of_month, close_date:Date.today.end_of_month)
      @p.organism_id = 1
      @p.stub(:organism).and_return o
      @p.stub(:should_not_have_more_than_two_open_periods).and_return(true)
      @p.stub(:check_nomenclature).and_return true
      @p.save! 
    end
  
    it 'se crée avec un exercice et un statut d organisme' do
      Utilities::PlanComptable.new(@p, 'Association').should be_an_instance_of(Utilities::PlanComptable)
    end

   
    it 'demande à period de créer les comptes lus dans le fichier' do
      Utilities::PlanComptable.create_accounts(@p, 'Association').should == 138
      @p.should have(138).accounts
    end

    it 'si p a déja des comptes ne crée pas de doublon' do
      @p.accounts.create!(number:'102', title:'Fonds associatif sans droit de reprise')
      Utilities::PlanComptable.create_accounts(@p, 'Association').should == 137
      @p.accounts(true).should have(138).accounts
    end

    it 'retourne 0 en cas d erreur sur la lecture' do
      Utilities::PlanComptable.create_accounts(@p, 'Inconnu').should == 0
    end
    
    it 'et 105 pour une entreprise' do
      Utilities::PlanComptable.create_accounts(@p, 'Entreprise').should == 122
    end

   

  end
  
  describe 'copy_accounts' do 
    
    let(:from_p) {mock_model(Period)}
    let(:to_p) {mock_model(Period)}
    
    before(:each) do
      from_p.stub_chain(:accounts, :where).and_return @from = 
          [@acc1 = stub_model(Account, used:true), @acc2 = stub_model(Account, used:true)]
    end
    
    subject {Utilities::PlanComptable.new(to_p, 'Association')}
    
    it 'prend la liste des comptes utilisés de from_period' do
      from_p.should_receive(:accounts).and_return(@from)
      @from.should_receive(:where).with('used = ?', true).and_return([@acc1])
      subject.copy_accounts(from_p)
    end
    
    it 'modifie le period_id' do
      @from.each do |f|
        f.should_receive(:dup).and_return f
        f.should_receive(:period_id=).with(to_p.id)
      end     
      subject.copy_accounts(from_p)
    end
    
    it 'puis appelle save' do
      @from.each do |f|
        f.stub(:dup).and_return f
        f.stub(:period_id=).and_return f
        f.should_receive(:save)
      end     
      subject.copy_accounts(from_p)
    end
    
    
  end

end