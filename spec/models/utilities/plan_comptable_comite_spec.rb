# coding: utf-8

require 'spec_helper'
require 'utilities/plan_comptable'

 

describe Utilities::PlanComptableComite do
  
  let(:o) {double(Organism, sectored?:false, database_name:SCHEMA_TEST)} 
  
  before(:each) do  
    
    Sector.create(organism_id:1, name:'ASC')
    Sector.create(organism_id:1, name:'Fonctionnement')
    Period.any_instance.stub(:organism).and_return o
    Account.any_instance.stub(:organism).and_return o
    
    @p = Period.new(start_date:Date.today.beginning_of_month, close_date:Date.today.end_of_month)
    @p.organism_id = 1
    @p.stub(:organism).and_return o
    @p.stub(:should_not_have_more_than_two_open_periods).and_return(true)
    @p.stub(:check_nomenclature).and_return true
    @p.save
    
  end
  
  describe 'create_accounts' do 
  
    it 'crée 106 compte pour un comité d entreprise' do
      Utilities::PlanComptableComite.create_accounts(@p).should == 104
    end
    
  end
  
end
