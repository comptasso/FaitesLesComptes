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
    create_minimal_organism
  end


  describe 'create archive' do

  
    it 'test create_minimal organism' do
      @o.should be_an_instance_of(Organism)
      @o.id.should == 1
    end

    it 'afficher la vue de organisme puis cliquer sur l icone sauvegarder renvoie sur la vue archive new' do
      visit admin_organism_path(@o)
      click_link("Fait une sauvegarde de toutes les données de l'organisme")
      page.find('.champ h3').should have_content "Création d'un fichier de sauvegarde"
      # current_url.should match new_admin_organism_archive_path(@o)
    end

    it 'remplir la vue et cliquer sur le bouton propose de charger un fichier', :wip=>true do
      visit new_admin_organism_archive_path(@o)
      fill_in 'archive[comment]', :with=>'test archive'
      filename = 'ASSO_TEST_'+ Date.today.to_s
      click_button 'new_archive_button'
      page.response_headers['Content-Disposition'].should match(%r(filename=\"#{filename}))
    end



  end


end
