#coding: utf-8

require 'spec_helper'

describe "transfers/new" do
  include JcCapybara

  before(:each) do
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
    page.all('form').should have(1).element
  end

  it 'forms points to'

  it 'check fields' do
    
  end


  it 'check the select fill_debitable' do
    render
    # FIXME : en fait ce devrait être 4 mais j'ai toujours une option vide
    page.find('#transfer_fill_debitable_id').all('option').should have(5).elements
    page.find('#transfer_fill_debitable_id').all('option').should have(5).elements 
  end
  
   it 'value should show class and id' do
    render
    page.find('#transfer_fill_debitable_id').find('option:nth-child(2)').value.should match /BankAccount_\d*/
    page.find('#transfer_fill_creditable_id').find('option:nth-child(2)').value.should match /BankAccount_\d*/
  end

 
end
