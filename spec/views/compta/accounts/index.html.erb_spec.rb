require 'spec_helper'

describe "compta/accounts/index" do
  include JcCapybara
  let(:p) {mock_model(Period, start_date:Date.today.beginning_of_year, end_date:Date.today.end_of_year)}


  before(:each) do
    assign(:period, p)
    assign(:compta_accounts, [
      stub_model(Account,
        :number => "60",
        :title => 'Compte achats' 
      ),
      stub_model(Account,
        :number => "603",
        :title => 'Stocks'
      )
    ])
  Account.any_instance.stub(:period).and_return(p)
  end

  it "renders a list of accounts" do 
    render
    assert_select "tr", :count => 3 # la ligne de titre et les deux lignes de comptes
    page.find('tbody tr:first td:first').should have_content('60')
    page.find('tbody tr:last td:first').should have_content('603')
  end

  it 'affiche si le compte est utilisé'
  it 'affiche l icone pdf pour imprimer'
end