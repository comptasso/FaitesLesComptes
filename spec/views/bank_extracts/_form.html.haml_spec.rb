# coding: utf-8

require 'spec_helper'

describe "bank_extracts/new" do 
  include JcCapybara 

  before(:each) do
    @o = assign(:organism, stub_model(Organism))
    @ba = assign(:bank_account, stub_model(BankAccount))
    @be = assign(:bank_extract, stub_model(BankExtract, :begin_date_picker=>'01/05/2012').as_new_record )
  end

   it 'view has one form' do
    render
    page.all('form').should have(1).element
  end

  it 'forms points to' do
    render
    assert_select "form", :action => organism_bank_account_bank_extracts_path(@o, @ba), :method => "post"
  end

  it 'check fields' do 
    render
    page.should have_css('input#bank_extract_begin_sold')
    page.should have_css('input#bank_extract_total_debit')
    page.should have_css('input#bank_extract_total_credit')
    page.should have_css('input#bank_extract_begin_date_picker')
    page.should have_css('input#bank_extract_end_date_picker')
    page.should have_css('.btn')
  end

  it 'date_fields have the right format' do
    render
    page.find('input#bank_extract_begin_date_picker').value.should == '01/05/2012'
  end

end
