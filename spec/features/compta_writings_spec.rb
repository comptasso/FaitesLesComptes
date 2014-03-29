# coding: utf-8

require 'spec_helper'

describe "Writings" do
  include OrganismFixtureBis


  before(:each) do
    use_test_user
    use_test_organism 
    login_as('quidam')
    # visit admin_room_path(@r)    
  end

  describe "GET compta/writings" do

    before(:each) do
      visit compta_book_writings_path(@od)
    end

    it "affiche le titre" do
      page.find('h3').should have_content 'Journal Opérations diverses : Liste d\'écritures'
    end
    
    it "le titre contient les liens vers les autres mois" do
      page.find('h3').should have_content 'fév.'
      page.find('h3').should have_content 'juil.'
    end

    # TODO compléter ces spec d'intégration
  end
end
