# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#RSpec.configure do |c|
  #  c.filter = {:js=> true }
  # c.filter = { :wip=>true}
  #  c.exclusion_filter = {:js=> true }
#end


describe 'resquest admin archive' do
  include OrganismFixture

  before(:each) do

    create_user
    create_minimal_organism
    login_as('quidam')
  end


  describe 'create archive' do

    it 'afficher la vue de organisme puis cliquer sur l icone sauvegarder renvoie sur la vue archive new' do
      visit admin_organism_path(@o)
      click_link("Fait une sauvegarde de toutes les données de l'organisme")
      page.find('.champ h3').should have_content "Création d'un fichier de sauvegarde"
      # current_url.should match new_admin_organism_archive_path(@o)
    end

    it 'remplir la vue et cliquer sur le bouton propose de charger un fichier', :wip=>true do
      visit new_admin_organism_archive_path(@o)
      fill_in 'archive[comment]', :with=>'test archive'
      filename = "assotest1 #{Time.now}.sqlite3"
      click_button 'new_archive_button'
      page.response_headers['Content-Disposition'].should have_content filename
      page.response_headers['Content-Disposition'].should have_content 'attachment;'
    end



  end


end
