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

  
  it "should have a unique number in the scope of bank and organism" do
    @cc = @o.cashes.new(name: 'Magasin')
    @cc.should_not be_valid
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
  
  context 'transferts' do

    

    it 'has a method debit_transfers' do
      @c.d_transfers.should  == []
    end

    it 'has a method credit_transfers' do
      @c.c_transfers.should  == []
    end
  end


end

