# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  #  c.exclusion_filter = {:js=> true } 
end

# spec request for testing admin cashes

describe 'admin cash' do
  include OrganismFixtureBis
  
  
  before(:each) do
    create_user
    create_minimal_organism 
    login_as('quidam')
    
  end


  describe 'new cash' do
    
    it 'remplir correctement le formulaire cree une nouvelle ligne' do
      visit new_admin_organism_cash_path(@o)
      fill_in 'cash[name]', :with=>'Entrepôt'
      
      click_button "Créer la caisse" # le compte'
    
      
    end

   

  end
 
  


end

