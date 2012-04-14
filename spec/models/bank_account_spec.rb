# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BankAccount do
  include OrganismFixture

  before(:each) do
    create_minimal_organism
  end

  before(:each) do
    @bb=@o.bank_accounts.new(:name=>'Crédit Universel', :number=>'1254L')
  end

  context 'controle des validités' do

  it "should be valid" do
    @bb.should be_valid
  end

  it 'should not be_valid without name' do
    @bb.name = nil
    @bb.should_not be_valid
  end

  it 'should not be_valid without name' do 
    @bb.number = nil
    @bb.should_not be_valid
  end

  it "should have a unique number in the scope of bank and organism" do
    @bb.name = @ba.name
    @bb.number= @ba.number
    @bb.should_not be_valid 
  end

  end

  context 'transferts' do

    it 'has a method debit_transfers' do
      @ba.d_transfers.should  == []
    end

    it 'has a method credit_transfers' do
      @ba.c_transfers.should  == []
    end
  end

end

