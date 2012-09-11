# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe 'Remise chèques' do

  include OrganismFixture

  before(:each) do
    create_user
    create_minimal_organism
    @n = Nature.create!(name: 'Vte Nourriture', period_id: @p.id, :income_outcome=>true) 

    login_as('quidam')
    @line = @ib.lines.new
    visit new_book_line_path(@ib)
    fill_in 'line_line_date_picker', :with=>'01/04/2012'
    fill_in 'line_narration', :with=>'Vente par chèque'
    select 'Vte Nourriture', :for=>'line_nature_id'
    fill_in 'line_credit', with: 50.21
    select 'Chèque'
    # select '5101 DebiX' : il n'y a pas de banque à sélectionner car on ne sait pas
    # encore sur quelle banque on va remettre le chèque
    
  end

  it 'lorsqu il n y pas de compte, ajoute une erreur au modèle' do
    click_button 'Créer'
    page.should have_content 'Impossible de trouver un compte de Chèques à l\'encaissement' 
  end

 it 'on crée une recette par chèque' do
   click_button 'Créer'
   Line.count.should == 2 # avec sa contrepartie 
 end


end
