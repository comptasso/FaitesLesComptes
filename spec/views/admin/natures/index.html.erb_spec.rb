# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/natures/index'  do


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

  it "should have title h3 Dépenses" do
    render
    rendered.should have_selector('h3') do |h3|
      h3.should contain 'Dépenses'
    end
  end
  
  it "should have title h3 Recettes" do
    render
    rendered.should have_selector('h3') do |h3|
      h3.should contain 'Recettes'
    end
  end

  it "should have two tables" do
    render
    rendered.should have_selector('table', :count=>2)
  end

  it "each body tables should have two lines" do
    render
    rendered.should have_selector('table tbody') do |tbody|
      tbody.should have_selector('tr', :count=>4)
    end
  end

  it "each line should show edit icon" do
    render
    rendered.should have_selector('tbody tr') do |row|
      row.should have_selector('img', :src=>'/assets/icones/modifier.png')
    end
  end

   it "each row should show edit icon" do
    render
    rendered.should have_selector('tbody tr') do |row|
      row.should have_selector('img', :src=>'/assets/icones/supprimer.png')
    end
  end

  it "with a line, row should not propose supprimer" do
    @recettes.first.stub_chain(:lines, :empty?).and_return(false)
    @depenses.first.stub_chain(:lines, :empty?).and_return(false)
    render
    rendered.should have_selector('tbody tr:first-child') do |row|
      row.should_not have_selector('img', :src=>'/assets/icones/supprimer.png') 
    end
  end


end

