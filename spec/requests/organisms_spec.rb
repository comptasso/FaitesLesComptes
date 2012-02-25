# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#describe "vue organisme"  do
#
#  let(:o) {stub_model(Organism) }
#  let(:ibook) {stub_model(IncomeBook, :title=>'Recettes') }
#  let(:obook) { stub_model(OutcomeBook, title: 'Dépenses')}
#  let(:p2012) {stub_model(Period, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))}
#  let(:p2011) {stub_model(Period, start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31)) }
#
#  before(:each) do
#   # assign(:organism, o)
#    o.stub(:periods).and_return([p2011,p2012])
#    p2012.stub(:previous_period?).and_return(true)
#    p2012.stub(:previous_period).and_return(p2011)
#    ibook.stub(:organism).and_return(o)
#    obook.stub(:organism).and_return(o)
#    ibook.stub_chain(:organism, :all).and_return([p2011, p2012])
#    obook.stub_chain(:organism, :all).and_return([p2011, p2012])
#  #  assign(:books, [ibook,obook])
#  #  assign(:period, p2012 )
#    o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque))
#  end
#
#  it "should render the dashboard" do
#    visit organism_path(o)
#    page.should have_content('Exercices')
#   end
#end

