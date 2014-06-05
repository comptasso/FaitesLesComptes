# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/natures/index'  do
  include JcCapybara

  before(:each) do
    assign(:organism, stub_model(Organism))  
    assign(:period, stub_model(Period)) 
    
    @natures = []
    @natures << mock_model(Nature, :period_id=>1, name: 'rec1', comment: 'rec1 comment')
    @natures << mock_model(Nature, :period_id=>1, name: 'rec2', comment: 'rec2 comment')
    @natures.each {|r| r.stub(:account).and_return(nil)}
   
    @natures.each {|r| r.stub_chain(:compta_lines, :empty?).and_return true }
   
    @book=  mock_model(Book, title:'Recettes')
    @book.stub_chain(:natures, :includes, :within_period, :order).and_return @natures
    

  end

  it "should have a h3 title" do  
    render
    page.find('h3').text.should == 'Natures du livre Recettes'
    
  end
  
  
  it "should have une table" do
    render
    page.all('table').should have(1).elements
  end

  it "avec deux lignes" do
    render
    page.all('table tbody tr').should have(2).elements

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
    @natures.first.stub_chain(:compta_lines, :empty?).and_return(false)
    render
    page.should_not have_css('tbody tr:first img[src="/assets/icones/supprimer.png"]')
  end 


end

