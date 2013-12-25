# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')


describe 'compta/balances/show' do 
  include JcCapybara

  def one_balance_line(i)
    {number:100, title:'le libelle', account_id:i, empty:false, cumul_debit_before:100, cumul_credit_before:50,
      total_debit:1000, total_credit:55, sold_at:2554
    }
  end
  
  let(:p) { mock_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year) }
  let(:b) { mock_model(Compta::Balance,
      period_id:p.id,
      from_date_picker:Date.today.beginning_of_year,
      to_date_picker:Date.today.end_of_year,
      from_date:Date.today.beginning_of_year,
      to_date:Date.today.end_of_year,
      from_account_id:1,
      to_account_id:10,
    total_balance:[1200,250]) }

  def list_accounts
    @accounts = 1.upto(10).collect {|i|  mock_model(Account, number:i.to_s, title:"compte #{i}", long_name:"#{i}-compte #{i}")           }
  end


  before(:each) do
    
    p.stub(:accounts).and_return list_accounts
    @accounts.stub(:order).and_return(@accounts)
    assign(:period, p)
    b.stub(:balance_lines).and_return((1..12).map {|i| one_balance_line(i)})

    view.stub(:export_icons).and_return '' 
    # TODO faire le spec de export_icons
    
  end
 
  it "page should have a a title and a firm" do
    b.stub(:provisoire?).and_return true
    assign(:balance, b)
    render
    page.find('h3').should have_content 'Balance provisoire' 
    
  end

  it 'si la balance est définitive' do
    b.stub(:provisoire?).and_return true
    assign(:balance, b)
    render
    page.find('h3').should have_content 'Balance'
  end

  it 'affiche la table des comptes' do
    b.stub(:provisoire?).and_return true
    assign(:balance, b)
    render
    page.all('table tbody tr').should have(12).lines
  end

  
end 

