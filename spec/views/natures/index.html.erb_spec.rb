# coding: utf-8

require 'spec_helper'
require 'list_months'

describe "natures/index" do  
  include JcCapybara

  let(:o) {mock_model(Organism, title: 'spec cd')}
  let(:p) {mock_model(Period, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year)}
  let(:ds) {[mock_model(Destination, name:'dest1'), mock_model(Destination, name:'Dest2')]}
  let(:sn) {double(Stats::Natures,
      :title=>(%w{Nature jan fev mar avr mai jui jui aou sep oct nov dec total}),
      :totals=>(['Totaux'] + 1.upto(12).collect {|i| '20,00'} + ['4800,00']),
      :lines=>(1.upto(4).collect {|i| ["Ligne #{i}"] + 1.upto(12).collect {|j| j}  + ['240,00']})
 

    ) }
  
  
  before(:each) do
    o.stub(:destinations).and_return ds 
    p.stub(:list_months).and_return(ListMonths.new(p.start_date, p.close_date))
    p.stub(:length).and_return 12  
    assign(:organism, o)
    assign(:period, p) 
    assign(:sn, sn)
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

    it "affiche dans la première colonne les natures" do
      page.find('tbody tr:first td:first').should have_content('Ligne 1') 
      page.find('tbody tr:last td:first').should have_content('Ligne 4')
    end

    it 'affiche les totaux dans la dernière colonne' do
      page.find('tbody tr:first td:last').should have_content('240,00')
      page.find('tbody tr:last td:last').should have_content('240,00')
    end

  end

  

 
end
