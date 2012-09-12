# coding: utf-8

require 'spec_helper'


describe "organisms/show" do
  


let(:o) {stub_model(Organism) } 
let(:ibook) {stub_model(IncomeBook, :title=>'Recettes') }
let(:obook) { stub_model(OutcomeBook, title: 'Dépenses')}
let(:p2012) {stub_model(Period, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))}
let(:p2011) {stub_model(Period, start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31)) }

before(:each) do
    assign(:organism, o)
    o.stub(:periods).and_return([p2011,p2012])
     o.stub(:find_period).and_return(p2012)
    p2012.stub(:previous_period?).and_return(true)
    p2012.stub(:previous_period).and_return(p2011)
    ibook.stub(:organism).and_return(o)
    obook.stub(:organism).and_return(o)
    ibook.stub_chain(:organism, :all).and_return([p2011, p2012])
    obook.stub_chain(:organism, :all).and_return([p2011, p2012])
    assign(:books, [ibook,obook])
    assign(:period, p2012 )
    assign(:paves, [ibook,obook,p2012])
    # assign(:p2011, p2011 )
    o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque))
   end

  # TODO revoir complètement car probablement totalement false positive

  it "renders show organism with graphics" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "#book_#{ibook.id}" do
     assert_select ".legend", 'Exercice 2011;Exercice 2012'
    end
  end

  it "renders show organism with graphics" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "#book_#{ibook.id}" do
     assert_select ".legend", 'Exercice 2011;Exercice 2012'
    end
  end

  context 'when active period is p2011' do

    before(:each) do
      assign(:period, p2011)
       p2011.stub(:previous_period?).and_return(false)
    end

     it "renders show organism with only a one year graphic" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "#book_#{ibook.id}" do
     assert_select ".legend", 'Exercice 2011'
    end
  end

  it "la légende ne doit pas faire apparaître Series 2 avec un seul exercice" do
    pending "Nécessite javascript contexte pour être testé"
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "td", 'Series 2', false
    
  end


  end
end

