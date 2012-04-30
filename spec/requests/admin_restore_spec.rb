# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  #c.filter = { :wip=>true}
  #  c.exclusion_filter = {:js=> true }
end

describe 'restoration de fichier' do
  include OrganismFixture


  before(:each) do
   

  end


  it 'accès par la vue admin#organism#show' , :js=>true do
    visit admin_organisms_path
    click_link("Permet de créer un organisme à partir d'un fichier de sauvegarde")
    alert = page.driver.browser.switch_to.alert
    alert.accept
    sleep 1
    current_url.should match new_admin_restore_path  
  end

  it 'remplir le formulaire et cliquer' , :wip=>true do
    visit new_admin_restore_path
    page.find('input#file_upload')
    attach_file('file_upload', "#{File.dirname(__FILE__)}/../fixtures/files/test_compta2.yml")
    click_button('Charger et vérifier le fichier')
    page.should have_content("Importation d'un fichier")
    click_button("Confirmer l'importation")
    page.all('table tbody tr').should have(1).row
    page.find('table tbody tr').should have_content('Test Compta Spec2')

    
  end








end