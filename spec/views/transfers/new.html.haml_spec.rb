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
    @t = stub_model(Transfer).as_new_record
    @t.stub(:compta_lines).and_return([mock_model(ComptaLine, 'editable?'=>true), mock_model(ComptaLine, 'editable?'=>false)])
    @t.stub(:partial_locked?).and_return false
    assign(:transfer, @t)

    @p.stub_chain(:list_bank_accounts, :to_a).and_return @bas
    @p.stub_chain(:list_cash_accounts, :to_a).and_return @cas
    

  end

  it 'view has one form' do
    render
    page.all('form').should have(1).element
  end

  it 'forms points to' do
    render
    assert_select "form", :action => transfers_path, :method => "post"
  end

  it 'check fields' do
    render
    page.should have_css('input#transfer_amount')
    page.should have_css('input#transfer_ref')
    page.should have_css('input#transfer_narration')
    page.should have_css('input#transfer_date_picker')
    page.should have_css('.btn')
  end
  
  it 'check que les champs narration sont disable si partial_locked'

  
  it 'check_select' do
    render
    page.all('select').should have(2).elements
  end


  it 'check the select ' do
    render
    page.find('select#transfer_compta_lines_attributes_1_account_id').all('option').should have(4).elements
    page.find('select#transfer_compta_lines_attributes_0_account_id').all('option').should have(4).elements
  end
  
  it 'check les select disable si editable? false'

 
end
