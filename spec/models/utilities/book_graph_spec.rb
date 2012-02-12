# To change this template, choose Tools | Templates
# and open the template in the editor.

# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Utilities::BookGraph do
  let(:b) {mock_model(Book)}
  let(:o) {mock_model(Organism)}
  let(:p1) {mock_model(Period, :start_date=>Date.civil(2010,01,01), :close_date=>Date.civil(2010,12,31))}
  let(:p2) {mock_model(Period, :start_date=>Date.civil(2011,01,01), :close_date=>Date.civil(2011,12,31))}

  context 'deux exercices de douze mois chacun, le deuxieme etant en cours' do
 
  before(:each) do
     b.stub(:organism).and_return(o)
     o.stub(:periods).and_return([p1,p2])
    # p1.stub(:nb_months).and_return(12)
     p2.stub(:nb_months).and_return(12)
     p2.stub(:previous_period?).and_return true
     p2.stub(:previous_period).and_return(p1)
     p2.stub(:list_months).with('%b').and_return(['jan', 'fev', 'mar', 'avr', 'mai', 'jui', 'jui', 'aou', 'sept', 'oct', 'nov', 'dec'])
     p1.stub(:list_months).with('%b').and_return(['jan', 'fev', 'mar', 'avr', 'mai', 'jui', 'jui', 'aou', 'sept', 'oct', 'nov', 'dec'])
     p2.stub(:exercice).and_return('Exercice 2011')
     p1.stub(:exercice).and_return('Exercice 2010')
     p2.stub(:list_months).with('%m-%Y').and_return(['01-2011', '02-2011','03-2011','04-2011','05-2011', '06-2011','07-2011','08-2011','09-2011', '10-2011','11-2011','12-2011'])
     p1.stub(:list_months).with('%m-%Y').and_return(['01-2011', '02-2011','03-2011','04-2011','05-2011', '06-2011','07-2011','08-2011','09-2011', '10-2011','11-2011','12-2011'])
     Line.stub_chain(:connection, :select_all).and_return( [{"Month"=>'01-2011','total_month'=>100},
                                                           {"Month"=>'02-2011','total_month'=>110},
                                                           {"Month"=>'03-2011','total_month'=>120},
                                                           {"Month"=>'04-2011','total_month'=>130},
                                                           {"Month"=>'05-2011','total_month'=>10},
                                                           {"Month"=>'06-2011','total_month'=>140},
                                                           {"Month"=>'07-2011','total_month'=>105},
                                                           {"Month"=>'08-2011','total_month'=>140},
                                                           {"Month"=>'10-2011','total_month'=>110},
                                                           {"Month"=>'11-2011','total_month'=>125},
                                                           {"Month"=>'12-2011','total_month'=>130}])
#     @book_graph.stub(:monthly_datas_for_chart).and_return(%w(100,110,120,120,100,95,200,100,120,150,180,120))
  end
 
  it "initialize correctement la legende et les ticks" do
   # b.stub_chain(:organism, :periods,:last).and_return(p2)
    @book_graph = Utilities::BookGraph.new(b) 
    @book_graph.ticks.should == %w(jan fev mar avr mai jui jui aou sept oct nov dec)
    @book_graph.legend.should == ['Exercice 2010', 'Exercice 2011']
  end

  it "initialise correctement les donnees" do
    @book_graph = Utilities::BookGraph.new(b)
    @book_graph.first_serie.should == [100, 110, 120, 130, 10, 140, 105,140,0,110,125,130]
  end

end

end