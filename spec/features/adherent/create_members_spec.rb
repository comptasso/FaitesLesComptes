# coding: utf-8

require 'spec_helper'

RSpec.configure do |c| 
 # c.filter = {:wip=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin bank_accounts 

describe 'création d un membre' do  
  include OrganismFixtureBis
  

  before(:each) do
    use_test_user
    use_test_organism 
    login_as('quidam')
    visit adherent.new_member_path 
  end
  
  after(:each) do
    Adherent::Member.delete_all
  end
  
  it 'La vue est celle d un nouveau membre' do
    page.should have_content('Nouveau membre')  
  end

  it 'créer un membre renvoie sur la saisie des coordonnées',  wip:true do
    fill_in "member_number", with:'Adh001'
    fill_in "member_name", with:'Lepage'
    fill_in "member_forname", with:'Jean-Claude'
    fill_in "member_birthdate", with:'06/06/1955'
    click_button "Créer le membre"
    page.should have_content('Saisie des coordonnées de Jean-Claude LEPAGE')
  end 
  
end