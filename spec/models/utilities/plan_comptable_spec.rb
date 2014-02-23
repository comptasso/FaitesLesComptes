# coding: utf-8

require 'spec_helper'
require 'utilities/plan_comptable'

describe Utilities::PlanComptable do  

  before(:each) do 
     
    @p = Period.new(start_date:Date.today.beginning_of_month, close_date:Date.today.end_of_month)
    @p.organism_id = 1
    @p.stub(:should_not_have_more_than_two_open_periods).and_return(true)
    @p.stub(:create_plan) # car create_plan est appelé par un after_create
    @p.stub(:create_bank_and_cash_accounts) # inutile de tester ce point ici
    @p.stub(:create_rem_check_accounts) # idem
    @p.stub(:fill_bridge)
    @p.stub(:load_natures)
    @p.save!
  end

  it 'se crée avec un exercice et un statut d organisme' do
    Utilities::PlanComptable.new(@p, 'Association').should be_an_instance_of(Utilities::PlanComptable)
  end

  describe 'self.create_accounts' do

    # TODO supprimer les spec similaires qui sont dans period_spec
    it 'demande à period de créer les comptes lus dans le fichier' do
      Utilities::PlanComptable.create_accounts(@p, 'Association').should == 137
      @p.should have(137).accounts
    end

    it 'si p a déja des comptes ne crée pas de doublon' do
      @p.accounts.create!(number:'102', title:'Fonds associatif sans droit de reprise')
      Utilities::PlanComptable.create_accounts(@p, 'Association').should == 136
      @p.accounts(true).should have(137).accounts
    end

    context 'en cas d erreur lors de la lecture du fichier' do

      it 'retourne 0 en cas d erreur sur la lecture' do
        Utilities::PlanComptable.create_accounts(@p, 'Inconnu').should == 0
      end

    end

  end
  
  describe 'copy_accounts' do
    
    let(:from_p) {mock_model(Period, :accounts=>@from = [stub_model(Account), stub_model(Account, dup:self)] )}
    let(:to_p) {mock_model(Period)}
    
    subject {Utilities::PlanComptable.new(to_p, 'Association')}
    
    it 'prend la liste des comptes de from_period' do
      from_p.should_receive(:accounts).and_return(@from)
      @from.each do |f|
        f.should_receive(:dup).and_return f
      end
      subject.copy_accounts(from_p)
    end
    
    it 'modifie le period_id' do
      from_p.stub(:accounts).and_return(@from)
      @from.each do |f|
        f.should_receive(:dup).and_return f
        f.should_receive(:period_id=).with(to_p.id)
      end     
      subject.copy_accounts(from_p)
    end
    
    it 'puis appelle save' do
      from_p.stub(:accounts).and_return(@from)
      @from.each do |f|
        f.should_receive(:dup).and_return f
        f.stub(:period_id=).and_return f
        f.should_receive(:save)
      end     
      subject.copy_accounts(from_p)
    end
    
    
  end

end