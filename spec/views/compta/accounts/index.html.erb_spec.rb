require 'spec_helper'

describe "compta/accounts/index" do
  before(:each) do
    assign(:accounts, [
      stub_model(Account,
        :number => "60",
        :title => 'Compte achats' 
      ),
      stub_model(Account,
        :number => "60",
        :title => 'Stocks'
      )
    ])
  end

  it "renders a list of accounts" do 
    render
    assert_select "tr>td", :text => "60".to_s, :count => 2
  end
end