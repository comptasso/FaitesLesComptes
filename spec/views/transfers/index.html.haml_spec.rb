# coding utf-8

require 'spec_helper'

describe "transfers/index" do
  include JcCapybara

  before(:each) do
    assign(:organism, mock_model(Organism, title: 'spec cd'))
        assign(:debitable, mock_model(BankAccount, name: 'Debix', number: '1254'))
        assign(:creditable, mock_model(BankAccount, name: 'Debix', number: '6789'))
        assign(:organism, mock_model(Organism, title: 'spec cd'))

    assign(:transfers, [
      stub_model(Transfer,
        :narration => "Premier virement",  
       :debitable => assigns(:debitable),
        :creditable => assigns(:creditable),
        :amount => 1.5,
        :date=> Date.today
      ),
      stub_model(Transfer,
        :narration => "Deuxieme Virement",
        :debitable => assigns(:debitable),
        :creditable => assigns(:creditable),
        :amount => 150,
        :date=> (Date.today-5)
      )
    ])
  end

  it "renders a list of transfers", :js=>true do
    render
    
    page.all('table').should have(1).elements
    page.find('table tbody').all('tr').should have(2).rows
    
    
  end
end
