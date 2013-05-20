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
    @p.stub(:load_natures)
    @p.save!
  end

  it 'se crée avec un exercice et un statut d organisme' do
    Utilities::PlanComptable.new(@p, 'Association').should be_an_instance_of(Utilities::PlanComptable)
  end

  describe 'self.create_accounts' do

    it 'demande à period de créer les comptes lus dans le fichier' do
      Utilities::PlanComptable.create_accounts(@p, 'Association').should == 87
      @p.should have(87).accounts
    end

    it 'si p a déja des comptes ne les écrase pas' do
      @p.accounts.create!(number:'101', title:'Fonds associatifs', :period_id=>@p.id)
      Utilities::PlanComptable.create_accounts(@p, 'Association').should == 86
      @p.accounts(true).should have(87).accounts
    end

    context 'en cas d erreur lors de la lecture du fichier' do

      it 'en cas d erreur sur la lecture : retourn 0' do
        Utilities::PlanComptable.create_accounts(@p, 'Inconnu').should == 0
      end

    end

  end

end