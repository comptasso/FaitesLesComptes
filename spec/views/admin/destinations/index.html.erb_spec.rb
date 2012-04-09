# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/destinations/index' do

  before(:each) do
    assign(:organism, stub_model(Organism))
    @destinations = []
    @destinations << mock_model(Destination, :organism_id=>1, name: 'dest1', comment: 'dest1 comment')
    @destinations << mock_model(Destination, :organism_id=>1, name: 'dest2', comment: 'dest2 comment')
    @destinations.each {|d| d.stub_chain(:lines, :empty?).and_return(true) }
  end

  context 'mise en page générale' do 
    before(:each) do
      render
    end
    
    it "should have title h3" do
      rendered.should have_selector('h3') do |h3|
        h3.should contain 'Liste des Destinations'
      end
    end

    it "should have one table" do
      rendered.should have_selector('table', :count=>1)
    end

    it "table body should have one line" do
      rendered.should have_selector('table tbody') do |tbody|
        tbody.should have_selector('tr', :count=>2)
      end
    end
    it "each row should show edit icon" do
      rendered.should have_selector('tbody tr') do |row|
        row.should have_selector('img', :src=>'/assets/icones/modifier.png')
      end
    end

    it "each row should show delete icon" do
      rendered.should have_selector('tbody tr') do |row|
        row.should have_selector('img', :src=>'/assets/icones/supprimer.png')
      end
    end
  end 

  # on ne peut le traiter comme les autres car le render ne doit pas arriver
  # avant le stub_chain
  context 'test de l affichage de l icone destroy' do
    it "with a line, row should not propose supprimer" do
      @destinations.first.stub_chain(:lines, :empty?).and_return(false)
      render

      rendered.should have_selector('tbody tr:first-child') do |row|
        row.should_not have_selector('img', :src=>"/assets/icones/supprimer.png")
      end
    end
  end
end

