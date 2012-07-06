# coding: utf-8

require 'spec_helper'

describe "natures/stats" do
  include JcCapybara

  let(:o) {mock_model(Organism, title: 'spec cd')}
  let(:p) {mock_model(Period, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year)}
  let(:ds) {[mock_model(Destination, name:'dest1'), mock_model(Destination, name:'Dest2')]}
  
  before(:each) do
    o.stub(:destinations).and_return ds
    
    assign(:organism, o)
    assign(:period, p)
    
    render
  end

  it "affiche le h3 statistiques par natures" do
    
    page.find('h3').should have_content "Statistiques par natures"
  end

  it "affiche un formulaire avec les destinations" do
    page.should have(1).form 
  end

  it "affiche une table avec autant de colonnes qu un exercice a de mois"

  it "affiche dans la première colonne les natures dans l'ordre alphabétique recettes puis dépenses"

  it "affiche dans les mois le montant correspondant"

 
end
