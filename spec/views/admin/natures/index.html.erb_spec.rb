# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/natures/index'  do
include JcCapybara

  before(:each) do
    assign(:organism, stub_model(Organism))
    assign(:period, stub_model(Period)) 
    @depenses = []
    @depenses << mock_model(Nature, :period_id=>1, name: 'dep1', comment: 'dep1 comment')
    @depenses << mock_model(Nature, :period_id=>1, name: 'dep2', comment: 'dep2 comment')
    @recettes = []
    @recettes << mock_model(Nature, :period_id=>1, name: 'rec1', comment: 'rec1 comment')
    @recettes << mock_model(Nature, :period_id=>1, name: 'rec2', comment: 'rec2 comment')
    @recettes.each {|r| r.stub(:account).and_return(nil)}
    @depenses.each {|r| r.stub(:account).and_return(nil)}
    @recettes.each {|r| r.stub_chain(:lines, :empty?).and_return true }
    @depenses.each {|r| r.stub_chain(:lines, :empty?).and_return true }


  end

  it "should have two titles h3" do
    render
    page.find('h3').text.should == 'Natures du type Recettes'
    page.find('h3:last').text.should == 'Natures du type Dépenses'
  end
  
  
  it "should have two tables" do
    render
    page.all('table').should have(2).elements
  end

  it "each body tables should have two lines" do
    render
    page.all('table tbody tr').should have(4).elements

  end

  it "each line should show edit icon" do
   render
   page.all('tbody tr img').first[:src].should match /\/assets\/icones\/modifier.png/
  end

   it "each row should show delete icon" do
    render
   page.all('tbody tr img').last[:src].should == '/assets/icones/supprimer.png'
  end

  it "with a line, row should not propose supprimer" do
    @recettes.first.stub_chain(:lines, :empty?).and_return(false)
    @depenses.first.stub_chain(:lines, :empty?).and_return(false)
    render
    page.should_not have_css('tbody tr:first img[src="/assets/icones/supprimer.png"]')
  end 


end

