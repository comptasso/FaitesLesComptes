# coding: utf-8

require 'spec_helper'

describe "organisms/show.html.erb" do
  include JcCapybara

  let(:o) {stub_model(Organism) }
  let(:ibook) {stub_model(IncomeBook, :title=>'Recettes') }
  let(:obook) { stub_model(OutcomeBook, title: 'Dépenses')}
  let(:p2012) {stub_model(Period, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))}
  let(:p2011) {stub_model(Period, start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31)) }

  before(:each) do
    assign(:organism, o)
    o.stub(:periods).and_return([p2011,p2012])
    p2012.stub(:previous_period?).and_return(true)
    p2012.stub(:previous_period).and_return(p2011)
    ibook.stub(:organism).and_return(o)
    obook.stub(:organism).and_return(o)
   # ibook.stub_chain(:organism, :all).and_return([p2011, p2012])
   # obook.stub_chain(:organism, :all).and_return([p2011, p2012])
    assign(:books, [ibook,obook])
    assign(:period, p2012 ) 
    o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque))
    assign(:paves, [ibook, obook, p2012])
  end

  describe 'Partie Virements du menu' do
    before(:each) do
      render :template=>'organisms/show', :layout=>'layouts/application'
    end

    it 'affiche le menu Virement' do
      page.find('ul#menu_general').should have_content('VIREMENTS')
    end

    it 'affiche le sous menu Afficher' do
      page.find('li#menu_transfer').should have_content('Afficher')
      
    end

    it 'affiche la sous rubrique Nouveau' do
      page.find('li#menu_transfer').should have_content('Nouveau')
    end
  end

  describe 'Partie Exercices du menu' do

    before(:each) do
      render :template=>'organisms/show', :layout=>'layouts/application'
    end

    it 'affiche la partie Exercices du menu' do
      rendered.should match('EXERCICES') 
    end

    it "affiche le sous menu exercice" do
      rendered.should match( organism_period_path(o, p2011)) 
    end



  end

end
