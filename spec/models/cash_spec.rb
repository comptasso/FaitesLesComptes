# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cash do
  include OrganismFixture

  before(:each) do
    create_minimal_organism
    
  end

  context 'test constraints' do
  it "should be valid" do
    @c.should be_valid
  end

  it 'should not be_valid without name' do
    @c.name = nil
    @c.should_not be_valid
  end

  
  it "should have a unique name in the scope of organism" do
    @cc = @o.cashes.new(name: 'Magasin')
    @cc.should_not be_valid
  end

  end

   describe 'création du compte comptable' do

    before(:each) do
      @c2=@o.cashes.new(:name=>'Dépôt')
    end

    it 'la création d un compte bancaire doit entraîner celle d un compte comptable' do
      @c2.save
      @c2.should have(1).accounts

    end

    it 'incrémente les numéros de compte' do
      @c.accounts.first.number.should == '5301'
      @c2.save
      @c2.accounts.first.number.should == '5302'
    end

    it 'crée le compte pour tous les exercices ouverts' do
      @o.periods.create!(:start_date=>(@p.close_date + 1), close_date:(@p.close_date.years_since(1)))
      @c2.save
      @c2.accounts.count.should == 2
    end

    it 'créer un nouvel exercice recopie le compte correspondant au compte bancaire' do
      @c.accounts.count.should == 1
      @o.periods.create!(:start_date=>(@p.close_date + 1), close_date:(@p.close_date.years_since(1)))
      @c.accounts.count.should == 2
      @c.accounts.last.number.should == @c.accounts.first.number
    end
  end

  

  context 'annex methods' do
    

    it 'to_s return name' do
      @c.to_s.should == @c.name
    end

    it 'to_option return cash_id' do
      @c.to_option.should == "Cash_#{@c.id}"
    end
  end

  # monthly_value est défini dans le module Utilities::Sold
  describe 'monthly_values' do

    it 'returns value at a date' do
      pending 'A revoir avec nouvelle logique des cash et en traitant la problématique de plusieurs exercices'
    end

  end
  
  

  
  context 'transferts' do

    

    it 'has a method debit_transfers' do
      @c.d_transfers.should  == []
    end

    it 'has a method credit_transfers' do
      @c.c_transfers.should  == []
    end
  end


end

