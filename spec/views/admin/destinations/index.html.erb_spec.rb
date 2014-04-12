# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/destinations/index' do
 include JcCapybara
  before(:each) do
    assign(:organism, stub_model(Organism)) 
    @destinations = []
    @destinations << mock_model(Destination, :organism_id=>1, name: 'dest1', comment: 'dest1 comment')
    @destinations << mock_model(Destination, :organism_id=>1, name: 'dest2', comment: 'dest2 comment')
    @destinations.each {|d| d.stub_chain(:compta_lines, :empty?).and_return(true) }
  end

  context 'mise en page générale' do 
    before(:each) do
      render
    end
    
    it "should have title h3" do
      page.find('h3').text.should match  'Liste des Activités'
      
    end

    it "should have one table" do
      page.all('table').should have(1).element
    end

    it "table body should have one line" do
      page.all('tbody tr').should have(2).elements
    end

    it "each row should show edit icon" do
      page.first('tbody tr:first img')[:src].should match /\/assets\/icones\/modifier.png/
      
    end

    it "each row should show delete icon" do
      page.find('tr:first a:last').find('img')[:src].should match /\/assets\/icones\/supprimer.png/
      
    end
  end 

  # on ne peut le traiter comme les autres car le render ne doit pas arriver
  # avant le stub_chain
  context 'test de l affichage de l icone destroy' do
    it "with a line, row should not propose supprimer" do
      @destinations.first.stub_chain(:compta_lines, :empty?).and_return(false)
      render
      page.should_not have_css('tbody tr:first img[src="/assets/icones/supprimer.png"]')
    end
  end
end

