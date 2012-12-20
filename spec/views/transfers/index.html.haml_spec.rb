# coding: utf-8

require 'spec_helper'

describe "transfers/index" do 
  include JcCapybara

  let(:caisse) {mock_model(Cash, nickname:'La caisse')}
  let(:banque) {mock_model(BankAccount, nickname:'La banque')}

  before(:each) do 
    assign(:organism, mock_model(Organism, title: 'spec cd'))

    @line_to =     assign(:line_to, mock_model(ComptaLine, locked?:false, account:mock_model(Account, number:'5101', accountable:banque)))
    @line_from =     assign(:line_from, mock_model(ComptaLine,locked?:false, account:mock_model(Account, number:'5301', accountable:caisse)))

        @t1 = stub_model(Transfer,
          :narration => "Premier transfert", 
          :date=> Date.today
        )
        @t1.stub(:amount).and_return(1.50)
        @t2 = stub_model(Transfer,
          :narration => "Deuxieme Transfert",
          :date=> (Date.today-5)
        )
        @t2.stub(:amount).and_return(150)

    assign(:transfers, [@t1,@t2])
    [@t1, @t2].each {|t| t.stub(:line_to).and_return @line_to }
    [@t1, @t2].each {|t| t.stub(:line_from).and_return @line_from}
   
    render
  end

  it "renders a list of transfers" do
    
    page.all('table').should have(1).elements
    page.find('table tbody').all('tr').should have(2).rows 
  end

  it 'have a h3 title' do
     page.find('.champ h3').should have_content ('Liste des transferts')
  end

  it 'with a thead and titles' do 
    thead = page.find('thead')
    thead.find('th:nth-child(1)').should have_content 'Date'
    thead.find('th:nth-child(2)').should have_content 'Libellé'
    thead.find('th:nth-child(3)').should have_content 'Montant'
    thead.find('th:nth-child(4)').should have_content 'De'
    thead.find('th:nth-child(5)').should have_content 'Vers'
    thead.find('th:nth-child(6)').should have_content 'Actions' 
  end

  it 'with a tbody with two rows' do
    page.all('tbody').should have(1).element
    page.all('tbody tr').should have(2).elements
  end
 
  it 'each row with relevant informations' do 
    first_row=page.find('tbody tr:first')
    first_row.find('td:nth-child(1)').should have_content(I18n::l Date.today)
    first_row.find('td:nth-child(2)').should have_content 'Premier transfert'
    first_row.find('td:nth-child(3)').should have_content '1.50'
    first_row.find('td:nth-child(4)').should have_content 'La caisse'
    first_row.find('td:nth-child(5)').should have_content 'La banque'
  end

  it 'test des icones pour les liens' do
    first_row=page.find('tbody tr:first')
    first_row.all('img').should have(2).icons
    first_row.all('img').first[:src].should == '/assets/icones/modifier.png'
    first_row.all('img').last[:src].should == '/assets/icones/supprimer.png'
  end
end
