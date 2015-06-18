# coding: utf-8

require 'spec_helper'

RSpec.configure do |c| 
  # c.filter = {:wip=>true}
end
  
  
describe "menus/_menu_analyse.html.erb" do 
  include JcCapybara 
  
  let(:o) {mock_model Organism}
  let(:p) {mock_model Period}
  let(:sect) {mock_model(Sector, name:'Global')}
  let(:fonc) {mock_model(Sector, name:'Fonctionnement')}
  let(:asc) {mock_model(Sector, name:'ASC')}
  
    
  before(:each) do
    view.stub('user_signed_in?').and_return true
    assign(:organism, o)
    assign(:period, p)
  end
  
  context 'Avec un seul secteur propose les liens' do
  
    before(:each) do
      o.stub(:sectors).and_return [sect]
      render :template=>'menus/_menu_analyse'
    end
    
    it 'Par Nature' do
      page.find_link("Par Natures")[:href].should == organism_period_natures_path(o, p)
    end
    
    it 'Par activités' do
      page.find_link("Par Activités")[:href].should == organism_period_destinations_path(o, p) 
    end
  
  end
  
  context 'Avec un comité d entreprise et donc trois secteurs', wip:true  do
    
    
    
    before(:each) do
      o.stub(:sectors).and_return [sect, fonc, asc]
      o.stub(:ce_sectors).and_return [fonc, asc]
      render :template=>'menus/_menu_analyse'
    end
    
    it 'Affiche toujours par Nature' do
      page.find_link("Par Natures")[:href].should == organism_period_natures_path(o, p)
    end
    
    it 'plus le nom des secteurs Fonctionnement' do
      page.find_link("Fonctionnement")[:href].should == 
        organism_period_destinations_path(o,p, sector_id:fonc.id)
    end
    
    it 'et ASC' do
      page.find_link("ASC")[:href].should == 
        organism_period_destinations_path(o,p, sector_id:asc.id)
    end
    
    
  end
  
end