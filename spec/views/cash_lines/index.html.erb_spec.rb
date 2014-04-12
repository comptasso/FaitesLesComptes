# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 # c.filter = {wip:true}
end

describe "cash_lines/index" do 
  include JcCapybara

  def mock_cash_line(montant)
    mock_model(ComptaLine,
      :debit=>montant,
    :date=>Date.today,
    :narration=>'le libellé',
    :destination=>double(:name=>'destinée'),
    :nature=>double(:name=>'une dépense'),
    :credit=>0,
    :ref=>'001',
    'editable?'=>true
  )
  end



  before(:each) do
    @cl1 = mock_cash_line(10)
    @cl2 = mock_cash_line(12.25)
    @p = mock_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
    @ca = mock_model(Cash, name:'Magasin')
    @ec = Extract::Cash.new(@ca, @p)
    @ec.stub(:lines).and_return([@cl1, @cl2])
    @ec.stub(:total_debit).and_return 25
    @ec.stub(:total_credit).and_return 25 




    assign(:cash, @ca)
    @view.stub(:submenu_mois).and_return(['jan', 'fev']) 
    @view.stub(:in_out_line_actions).and_return('les actions')
   

    assign(:mois, Date.today.month)
    assign(:an, Date.today.year)
    assign(:monthly_extract, @ec)
    render
  end

  it 'should render avec une table' do
    page.all('table').should have(1).element
  end

  it 'avec une ligne de titre' do
    titles = page.all('thead th').collect {|el| el.text}
    titles.should == %w(Date Réf Libellé Activité Nature Sorties Entrées Actions)

  end
  it 'deux lignes' do
    page.all('table tbody tr').should have(2).lines
  end

  it 'une ligne se compose de ...' do
    ligne = page.all('table tbody tr:first td')
    ligne.first.text.should == I18n.l(Date.today, :format=>'%d/%m/%Y')
    ligne[1].text.should == '001'
    ligne[2].text.should == 'le libellé'
    ligne[3].text.should == 'destinée'
    ligne[4].text.should == 'une dépense'
    ligne[5].text.should == '-'
    ligne[6].text.should == '10,00'
  end

  


end
