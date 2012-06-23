# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  # c.filter = { :wip=>true}
  #  c.exclusion_filter = {:js=> true }
end

describe 'restoration de fichier' do 
  include OrganismFixture



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
    pending "crée un problème dans la base test il faudrait probablement une transaction"
    visit new_admin_restore_path
    page.find('input#file_upload')
    attach_file('file_upload', "#{File.dirname(__FILE__)}/../fixtures/files/test_compta2.yml")
    click_button('Charger et vérifier le fichier')
    page.should have_content("Importation d'un fichier")
    sleep 1
    click_button("Confirmer l'importation")
 
    page.all('table tbody tr').should have(1).row
    page.find('table tbody tr').should have_content('Test Compta Spec2')

    
  end

  it 'with a valid yml file go to confirmation' , :wip=>true  do
    pending "crée un problème dans la base test il faudrait probablement une transaction"
    visit new_admin_restore_path 
    attach_file('file_upload', "#{File.dirname(__FILE__)}/../fixtures/files/test_compta2.yml")
    click_button('Charger et vérifier le fichier')
    page.should have_content("Importation d'un fichier")
    
  end

end