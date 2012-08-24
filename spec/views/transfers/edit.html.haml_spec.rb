#coding: utf-8

require 'spec_helper'

describe "transfers/edit" do
    include JcCapybara

  before(:each) do
    ActiveRecord::Base.stub!(:use_org_connection).and_return(true)  # pour éviter
    # l'appel d'establish_connection dans le before_filter find_organism
    @o = assign(:organism, stub_model(Organism))
    @bas= assign(:bank_accounts,
    [stub_model(BankAccount, name: 'DebiX', number: '1234Z'),
    stub_model(BankAccount, name: 'DebiX', number: '5678Z') ])
    @cas = assign(:cashes,
     [stub_model(Cash, name: 'Magasin'),
    stub_model(BankAccount, name: 'Entrepôt') ])
    @p= assign(:period, stub_model(Period, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year))


    @o.stub_chain(:bank_accounts, :all).and_return @bas
    @o.stub_chain(:cashes, :all).and_return @cas

    @transfer = assign(:transfer, stub_model(Transfer, :pick_date=>'12/04/2012', :fill_creditable=>"BankAccount_1",
        :fill_debitable=>'Cash_2', :amount=>50.23, narration: 'virement'))

    @transfer.stub(:debit_locked?).and_return(false)
    @transfer.stub(:credit_locked?).and_return(false)
    @transfer.stub(:partial_locked?).and_return(false)
  end

  it "renders the edit transfer form" do
    render
    page.all('form').should have(1).element
    assert_select "form", :action => organism_transfers_path(@o), :method => "post" 
  end

  describe 'a transfer partially locked has fields disabled' do

   
  it "debit is locked" do
    @transfer.should_receive(:partial_locked?).and_return(true, true, true)
    render
    
    page.find('input#transfer_date_picker')[:disabled].should == 'disabled'
    page.find('input#transfer_narration')[:disabled].should == 'disabled'
    page.find('input#transfer_amount')[:disabled].should == 'disabled'
  end

  it 'part debit is disable if line_debit locked' do
     @transfer.should_receive(:debit_locked?).and_return(true)
     render
     page.find('select#transfer_fill_debitable')[:disabled].should == 'disabled'
     page.find('select#transfer_fill_creditable')[:disabled].should be_nil
  end

    it 'part credit is disable if line_credit locked' do
    @transfer.should_receive(:credit_locked?).and_return(true)
     render
     page.find('select#transfer_fill_creditable')[:disabled].should == 'disabled'
     page.find('select#transfer_fill_debitable')[:disabled].should be_nil
  end

  end
  
end
