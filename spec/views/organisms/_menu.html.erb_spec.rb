# coding: utf-8

require 'spec_helper'

describe "organisms/show.html.erb" do

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
    ibook.stub_chain(:organism, :all).and_return([p2011, p2012])
    obook.stub_chain(:organism, :all).and_return([p2011, p2012])
    assign(:books, [ibook,obook])
    assign(:period, p2012 ) 
    o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque))
  end

  describe 'Partie Exercices du menu' do

    before(:each) do
      render :template=>'organisms/show', :layout=>'layouts/application'
    end

    it 'affiche la partie Exercices du menu' do
      rendered.should match('Exercices')
      rendered.should match('Précédent')
      # rendered.should match('Suivant')
    end

    it 'affiche le sous menu Exercices' do
      rendered.should have_selector('ul#menu_exercices') do |menu|
        menu.should have_selector('li',content: 'Afficher')
        menu.should have_selector('a', href: organism_periods_path(o))
        menu.should have_selector('li',content: '2011')
        menu.should have_selector('li',content: '2012')
      end
 
    end

  end

end
