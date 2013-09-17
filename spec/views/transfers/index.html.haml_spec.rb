# coding: utf-8

require 'spec_helper'

describe "transfers/index" do 
  include JcCapybara 

  let(:caisse) {mock_model(Cash, nickname:'La caisse')}
  let(:banque) {mock_model(BankAccount, nickname:'La banque')}

  before(:each) do 
    assign(:organism, mock_model(Organism, title: 'spec cd'))
    assign(:period, mock_model(Period, :list_months=>[MonthYear.from_date(Date.today)])) # dans le test, on n'affiche qu'un seul mois

    @line_to = assign(:line_to, mock_model(ComptaLine, editable?:true, account:mock_model(Account, number:'5101', accountable:banque)))
    @line_from = assign(:line_from, mock_model(ComptaLine,editable?:true, account:mock_model(Account, number:'5301', accountable:caisse)))

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
   
    
  end

  describe 'la vue' do
    
    before(:each) do
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
      page.find('tbody tr:first') do
        find('td:nth-child(1)').should have_content(I18n::l Date.today)
        find('td:nth-child(2)').should have_content 'Premier transfert'
        find('td:nth-child(3)').should have_content '1.50'
        find('td:nth-child(4)').should have_content 'La caisse'
        find('td:nth-child(5)').should have_content 'La banque'
      end
    end
  
  end
  
  describe 'les icones d actions' do
    
    it 'test des icones pour les liens' do
      @t1.stub(:editable?).and_return true
      @t1.stub(:destroyable?).and_return true
      render
      page.find('tbody tr:first') do
        all('img').should have(2).icons
        find('img:first')[:src].should == '/assets/icones/modifier.png'
        find('img:last')[:src].should == '/assets/icones/supprimer.png'
      end
    end
  
    it 'si non destroyable, l icone destroyable n apparait pas' do
      @t1.stub(:editable?).and_return true
      @t1.stub(:destroyable?).and_return false
      render
      page.find('tbody tr:first') do
        all('img').should have(1).icons
        first('img')[:src].should == '/assets/icones/modifier.png'
      end
    end
    
    it 'si non editable, l icone edit n apparait pas' do
      @t1.stub(:editable?).and_return false
      @t1.stub(:destroyable?).and_return false
      render
      page.find('tbody tr:first') do
        all('img').should have(0).icons
      end
    end
  
  end
end
