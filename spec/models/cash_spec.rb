# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
 #  c.filter = {wip:true} 
end

describe Cash  do
  include OrganismFixtureBis
  
  def stubca 
    c = Cash.new(name:'Local')
    c.organism_id = 1; c.sector_id = 1 
    c
  end

  subject {stubca}
  
  context 'test validité' do 
    
    before(:each) do
      Cash.delete_all
    end
 
    it {should be_valid}
  
    it 'should not be_valid without name' do 
      subject.name = nil
      subject.should_not be_valid
    end

  
    it "should have a unique name in the scope of organism" do
      subject.stub_chain(:organism, :periods, :opened).and_return [] # pour ne pas
      subject.save
      cc = Cash.new(name:'Local', sector_id:1); cc.organism_id = 1
      cc.should have(1).errors_on(:name)
    end

  end

  describe 'création du compte comptable'  do
    
    subject {stubca}
    
    before(:each) do
      Cash.delete_all
      subject.stub_chain(:organism, :periods, :opened).and_return [double(Period)]
    end
        
    it 'la création d un compte bancaire doit entraîner celle d un compte comptable' do
      Utilities::PlanComptable.should_receive(:create_financial_accounts).with(subject)
      subject.save!
    end

    it 'incrémente les numéros de compte' do
      pending 'A tester dans Utilities::PlanComptable'
      @c.accounts.first.number.should == '5301'
      @c2.save
      @c2.accounts.first.number.should == '5302'
    end

    it 'crée le compte pour tous les exercices ouverts' do
      pending 'A tester dans Utilities::PlanComptable'
      @o.periods.create!(:start_date=>(@p.close_date + 1), close_date:(@p.close_date.years_since(1)))
      @c2.save
      @c2.accounts.count.should == 2
    end

    it 'créer un nouvel exercice recopie le compte correspondant au compte bancaire' do 
      pending 'A tester dans Utilities::PlanComptable'
      @c.accounts.count.should == 1
      @o.periods.create!(:start_date=>(@p.close_date + 1), close_date:(@p.close_date.years_since(1)))
      @c.accounts.count.should == 2
      @c.accounts.last.number.should == @c.accounts.first.number
    end
  end
  
  describe 'la modification du nom' , wip:true do
    
    subject do
      c = Cash.find_by_name('Local')  || stubca
      c.save! unless c.persisted?
      c
    end
    
    before(:each) do
      Cash.delete_all
      Cash.any_instance.stub_chain(:organism, :periods, :opened).and_return []
    end
    
    it 'entraine l appel de change_account_title' do
      subject.should_receive(:change_account_title)
      subject.name = 'Secrétariat'
      subject.save
      
    end
    
    it 'chaque compte recoit update_attribute' do
      pending 'à mettre au point'
      @acc1.should_receive(:update_attribute) #.with(:name, 'Caisse Secrétariat')
      @acc2.should_receive(:update_attribute).with(:name, 'Caisse Secrétariat')
    end
    
  end

  

  context 'annex methods' do

    it 'to_s return name' do
      subject.to_s.should == subject.name
    end
    
    it {should respond_to(:monthly_value)}
  
  end
  
 

  

   

  
  
end