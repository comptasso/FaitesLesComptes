# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#RSpec.configure do |c|
  #  c.filter = {:js=> true }
  # c.filter = { :wip=>true}
  #  c.exclusion_filter = {:js=> true } 
#end


describe 'resquest admin archive' do    
  include OrganismFixtureBis

  before(:each) do

    create_user
    create_minimal_organism   
    login_as('quidam')
  end


  describe 'create archive' do  

   

    it 'remplir la vue et cliquer sur le bouton propose de charger un fichier' do
      visit new_admin_organism_archive_path(@o) 
      fill_in 'archive[comment]', :with=>'test archive'
      
      click_button 'new_archive_button'
      name = "assotest1 #{I18n.l Time.now}"
      # pour éviter d'avoir des erreurs liées à un changement de seconde
      # pendant le test, on isole le dernier chiffre et on crée une expression
      # régulière
      filename = name[0,name.length-2]+'[0-5][0-9]'
      cd = page.response_headers['Content-Disposition']
      cd[/attachment; filename=(.*)[\.sqlite3|\.dump]/]
      $1.should match filename # contrôle du titre du fichier
      
    end



  end


end
