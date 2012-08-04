# coding: utf-8 

require 'spec_helper'

describe "admin/steps/show" do
  include JcCapybara

  it 'affiche le message de bienvenue' do
    assign(:organism, mock_model(Organism))
    render
    page.find('h3:first').should have_content('Bienvenue sur Faites les comptes')
    page.find('h3:first + div').should have_content('démarrer rapidement en quelques étapes')
  end


  context 'Etape 1' do

    before(:each) do
      assign(:step, 1)
      assign(:organism, mock_model(Organism))
    end

    it 'si première étape, il affiche le formulaire de création de l organisme' do
      render
      page.find('h3#step1').should have_content("Etape 1 : Création de l'organisme")
    end

    it 'le formulaire organsime est affiché' do
    
      render
      page.all('#form1').should have(1).element
    end

    it 'le form 1 n est pas affiché pour les autes étapes que 1' do
      assign(:step, 2)
      render
      page.all('#form1').should have(0).element
    end
  
    it 'affiche juste les titres des autres étapes' do
      render
      page.all('form').should have(1).element
      page.all('h3').should have(4).elements
    end

  end
end
