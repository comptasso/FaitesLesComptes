# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  #  c.exclusion_filter = {:js=> true }
end

describe 'Statistiques' do 
  include OrganismFixtureBis
  

  before(:each) do
    create_user
    create_minimal_organism
    login_as('quidam')
  end

  describe 'stats' do
    before(:each) do
      visit organism_period_natures_path(@o, @p) 
    end

    it 'should be a succes' do
      page.should have_content('Statistiques par natures')
    end

    it 'choisir un filtre et rafraichir réaffiche la page' do
      pending 'en attente de fixtures plus complètes'
      
    end
  end
end
