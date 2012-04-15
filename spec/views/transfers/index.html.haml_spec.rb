# coding: utf-8

require 'spec_helper'

describe "transfers/index" do
  include JcCapybara

  before(:each) do
    assign(:organism, mock_model(Organism, title: 'spec cd'))
    @debitable =     assign(:debitable, mock_model(BankAccount, name: 'Debix', number: '1254'))
    @creditable =     assign(:creditable, mock_model(BankAccount, name: 'Debix', number: '6789'))
    assign(:organism, mock_model(Organism, title: 'spec cd'))

    assign(:transfers, [
        stub_model(Transfer,
          :narration => "Premier virement",
          :debitable => @debitable,
          :creditable => @creditable,
          :amount => 1.5,
          :date=> Date.today
        ),
        stub_model(Transfer,
          :narration => "Deuxieme Virement",
          :debitable =>  @debitable,
          :creditable => @creditable,
          :amount => 150,
          :date=> (Date.today-5)
        )
      ])
    [@debitable, @creditable].each do |dc|
      dc.stub(:model_name).and_return('BankAccount')
      dc.stub(:to_s).and_return('DebiX Cte n° 1254')
    end
    render
  end

  it "renders a list of transfers" do
    
    page.all('table').should have(1).elements
    page.find('table tbody').all('tr').should have(2).rows 
  end

  it 'have a h3 title' do
   
    page.find('.champ h3').should have_content ('Liste des virements')
  end

  it 'with a thead and titles' do 
    thead = page.find('thead')
    thead.find('th:nth-child(1)').should have_content 'Date'
    thead.find('th:nth-child(2)').should have_content 'Libellé'
    thead.find('th:nth-child(3)').should have_content 'Montant'
    thead.find('th:nth-child(4)').should have_content 'Débité'
    thead.find('th:nth-child(5)').should have_content 'Crédité'
    thead.find('th:nth-child(6)').should have_content 'Actions' 
  end

  it 'with a tbody with two rows' do
    page.all('tbody').should have(1).element
    page.all('tbody tr').should have(2).elements
  end
 
  it 'each row with relevant informations' do 
    first_row=page.find('tbody tr:first')
    first_row.find('td:nth-child(1)').should have_content(I18n::l Date.today)
    first_row.find('td:nth-child(2)').should have_content 'Premier virement'
    first_row.find('td:nth-child(3)').should have_content '1.50'
    first_row.find('td:nth-child(4)').should have_content 'DebiX Cte n° 1254'
    first_row.find('td:nth-child(5)').should have_content 'DebiX Cte n° 1254'
  end

  it 'test des icones pour les liens' do
    first_row=page.find('tbody tr:first')
    first_row.all('img').should have(2).icons
    first_row.all('img').first[:src].should == '/assets/icones/modifier.png'
    first_row.all('img').last[:src].should == '/assets/icones/supprimer.png'
  end
end
