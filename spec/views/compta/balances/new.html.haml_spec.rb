# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')


describe 'compta/balances/new' do 
  include JcCapybara
  
  let(:p) { mock_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year) }
  let(:b) { double(Compta::Balance, period_id:p.id,from_date:Date.today.beginning_of_year, to_date:Date.today.end_of_year) }

  def list_accounts
    @accounts = 1.upto(10).collect {|i|  mock_model(Account, number:i.to_s, title:"compte #{i}", long_name:"#{i}-compte #{i}")           }
  end


  before(:each) do
    c = Compta::Balance.new(period_id:p.id, from_date:Date.today.beginning_of_year, to_date:Date.today.end_of_year)
    p.stub(:accounts).and_return list_accounts
    @accounts.stub(:order).and_return(@accounts)
    assign(:balance, c )
    assign(:period, p)
    render
  end
 
  it "page should have a a title and a firm" do
    page.should have_content 'Paramètres de la balance'
    page.all('form').should have(1).form
  end

  it 'le form doit avoir 4 champs et un bouton' do
    page.find('input#compta_balance_from_date_picker').value.should == I18n::l(Date.today.beginning_of_year)
    page.find('input#compta_balance_to_date_picker').value.should == I18n::l(Date.today.end_of_year)
  end

  it 'le form a deux champs select qui affichent la liste des comptes' do
    page.find('select#compta_balance_from_account_id').all('option').should have(10).elements
    page.find('select#compta_balance_from_account_id').first('option').text.should == '1-compte 1'
    page.find('select#compta_balance_to_account_id').all('option').should have(10).elements
    page.find('select#compta_balance_to_account_id').first('option:last').text.should == '10-compte 10'
  end
end 

