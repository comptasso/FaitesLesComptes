# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  # c.filter = { :wip=>true}
   # c.exclusion_filter = {:js=> true }
end

describe 'restoration de fichier' do 
  include OrganismFixture

  before(:each) do
    create_user
    create_minimal_organism
    login_as('quidam')
  end
    

  
  it 'accès par la vue admin#organism#show' , :js=>true do
    visit admin_organisms_path
    page.find('a', :href=>new_admin_restore_path)
    click_link("Permet de créer un organisme à partir d'un fichier de sauvegarde")
    alert = page.driver.browser.switch_to.alert
    sleep 0.1 
    alert.accept
    page.find('.champ h3').should have_content "Restauration d'un organisme à partir d'un fichier"
  end



  it 'remplir le formulaire et cliquer conduit à la vue organism#index' do
    visit new_admin_restore_path
    page.find('input#file_upload')
    attach_file('file_upload', "#{File.dirname(__FILE__)}/../fixtures/files/testv064.sqlite3")
    fill_in 'database_name', :with=>'testload'
    click_button('Charger le fichier et créer la base')
    page.should have_content("Le fichier a été chargé et peut servir de base de données")
    page.all('table tbody tr').should have(2).rows
    page.find('table tbody tr:last').should have_content('Tennis Club')
  end

  

end