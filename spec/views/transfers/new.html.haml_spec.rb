#coding: utf-8

require 'spec_helper'

describe "transfers/new" do 
  include JcCapybara

  before(:each) do
    @o = assign(:organism, stub_model(Organism))
    @bas= assign(:accounts,
    [stub_model(Account, number: '5101'),
    stub_model(Account, number: '5102') ])
    @cas = assign(:cashes,
     [stub_model(Account, number: '5301'),
    stub_model(Account, number: '5302') ])
    @p  = assign(:period, stub_model(Period, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year))
    assign(:transfer, stub_model(Transfer).as_new_record)

    @p.stub_chain(:bank_accounts, :all).and_return @bas 
    @p.stub_chain(:cash_accounts, :all).and_return @cas
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
    
    page.find('#transfer_to_account_id').all('option').should have(4).elements
    page.find('#transfer_from_account_id').all('option').should have(4).elements
  end
  
  

 
end
