# coding: utf-8

require 'spec_helper'
require 'list_months'

describe "natures/stats" do
  include JcCapybara

  let(:o) {mock_model(Organism, title: 'spec cd')}
  let(:p) {mock_model(Period, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year)}
  let(:ds) {[mock_model(Destination, name:'dest1'), mock_model(Destination, name:'Dest2')]}
  values =  [1,1,1,1,1,1,1,1,1,1,1,1,12]
  
  
  before(:each) do
    o.stub(:destinations).and_return ds
    p.stub(:list_months).with('%b %y').and_return(ListMonths.new(p.start_date, p.close_date))
    assign(:organism, o)
    assign(:period, p)
    assign(:total_recettes, [1,2,3,4,5,6,7,8,9,10,11,12])
    assign(:total_depenses, [11,12,13,14,15,16,17,18,19, 20, 21, 22])

    assign(:recettes, [ mock(Object, name:'recette 1', :stat_with_cumul=>values),mock(Object, name:'recette 2', :stat_with_cumul=>values) ])
    assign(:depenses,  [ mock(Object, name:'depense 1', :stat_with_cumul=>values),mock(Object, name:'depense 2', :stat_with_cumul=>values) ])
    render
  end

  it "affiche le h3 statistiques par natures" do
    page.find('h3').should have_content "Statistiques par natures"
  end

  it "affiche un formulaire avec les destinations" do
    page.all('form').should have(1).element
  end

  describe 'la table' do
    it "affiche 2 colonnes  de plus qu un exercice a de mois" do
      page.all('table thead th').should have(14).columns # l'intitulé, les 12 valeurs et le total
    end

    it 'le corps affiche ici 4 rangées' do
      page.all('tbody tr').should have(4).rows
    end

    it "affiche dans la première colonne les natures dans l'ordre alphabétique recettes puis dépenses" do
      page.find('tbody tr:first td:first').should have_content('recette 1')
      page.find('tbody tr:last td:first').should have_content('depense 2')
    end

    it 'affiche les totaux dans la dernière colonne' do
      page.find('tbody tr:first td:last').should have_content('12')
      page.find('tbody tr:last td:last').should have_content('12')
    end

  end

  

 
end
