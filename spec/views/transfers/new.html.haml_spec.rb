#coding: utf-8

require 'spec_helper'

describe "transfers/new" do
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
    assign(:transfer, stub_model(Transfer).as_new_record)

    @o.stub_chain(:bank_accounts, :all).and_return @bas
    @o.stub_chain(:cashes, :all).and_return @cas
  end

  it 'view has one form' do
    render
    page.all('form').should have(1).element
  end

  it 'forms points to' do
   @t = assign(:transfer, stub_model(Transfer).as_new_record )
    render
    assert_select "form", :action => organism_transfers_path(@o), :method => "post"
  end

  it 'check fields' do
    render
    page.should have_css('input#transfer_amount')
    page.should have_css('input#transfer_narration')
    page.should have_css('input#transfer_date_picker')
    page.should have_css('.btn')
  end


  it 'check the select ' do
    render
    
    page.find('#transfer_fill_debitable').all('option').should have(4).elements
    page.find('#transfer_fill_creditable').all('option').should have(4).elements
  end
  
   it 'value should show class and id' do
    render
    page.find('#transfer_fill_debitable').find('option:nth-child(2)').value.should match /BankAccount_\d*/
    page.find('#transfer_fill_creditable').find('option:nth-child(2)').value.should match /BankAccount_\d*/
  end

 
end
