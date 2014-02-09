require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe "admin rooms" do
   
  include OrganismFixtureBis
  
  describe 'Création d un premier organisme' do 
  
    before(:each) do
      create_only_user
      login_as('quidam')
    end
  
    it 'la page rendue doit être la page de création d un organisme' do
      page.find('h3').should have_content 'Nouvel organisme' 
    end
  
    context 'quand je remplis le formulaire' do
      
      
    before(:each) do 
      Apartment::Database.process('assotest1') {  Organism.all.each {|o| o.destroy } }
      visit new_admin_room_path
      fill_in 'organism_title', with:'Mon association'
      fill_in 'organism_comment', with:'Une première'
      fill_in 'organism_database_name', with:'assotest1'
      choose 'Association'
    end
    
    it 'cliquer sur le bouton crée un organisme'  do
      
      expect {click_button 'Créer l\'organisme'}.to change {Organism.count}.by(1)
    end
    
    it 'renvoie sur la page de création d un exercice' do
      
      click_button 'Créer l\'organisme'
      page.find('h3').should have_content 'Nouvel exercice' 
    end
  
    it "et met à jour le cache" do
      
      click_button 'Créer l\'organisme'
      page.all('#admin_organisms_menu ul li a').should have(2).elements
      page.first('#admin_organisms_menu ul li a').text.should == 'Liste des organismes'
      page.find('#admin_organisms_menu ul li:last a').text.should == 'Mon association'
    end
    end
  end
  
  context 'avec un organisme existant'  do
    
    before(:each) do
      create_user
      create_minimal_organism
      login_as('quidam')
      visit admin_rooms_path
    end
    
    # TODO déplacer ça dans un test de vue    
    it 'la vue index affiche une table avec une ligne, le titre et le commentaire' do
      
      page.find('h3').should have_content 'Liste des organismes'
      page.all('tbody tr').should have(1).line
      page.find('tbody tr td:first').text.should == @o.title
      page.find('tbody tr td:nth-child(2)').text.should == @o.comment
    end
   
  
  
  describe 'cloner un organisme' do
    
      it 'crée un clone' do
        visit admin_organism_path(@o.to_param)
        click_link 'Fait un clone de l\'organisme'
        fill_in('Commentaire', with:'Test de clone par admin_rooms_features')
        click_button('Cloner la base')
        current_path.should == admin_rooms_path
        page.should have_content('Test de clone par admin_rooms_features')
      end
    
  end
  
    describe 'test du menu' do
      
      it 'affiche les liens vers les différentes pièces' do
        # 3 car un pour organisms, un pour le divider et un pour l'organism Asso Test
        find_by_id('admin_organisms_menu').find('ul').all('li').count.should == 3 
      end
    end
  
  
  
  describe 'destruction d un organisme' do
    before(:each) do
      visit admin_organism_path(@o.to_param)
      click_link 'Fait un clone de l\'organisme'
      fill_in('Commentaire', with:'Test de clone par admin_rooms_features')
      click_button('Cloner la base')
      @clone_room = Room.order('created_at ASC' ).last
      @clone_org = @clone_room.organism
      
    end
    
    it 'supprime l organisme', js:true do
      nbr = Room.count
      visit admin_room_path(@clone_room)
      click_link 'Supprimer'
      alert = page.driver.browser.switch_to.alert 
      alert.accept 
      sleep 1
      Room.count(true).should == nbr -1
    end
    
      
    
    it 'le menu organisme est mis à jour', js:true, wip:true do
      pending
      visit admin_rooms_path
      sleep 2
#      within('admin_organisms_menu')
#      page.should have_content('ASSO TEST')
     elem = find_by_id('admin_organisms_menu')
     node = elem.native
     puts node.inspect
     puts node.html
     #find_by_id('admin_organisms_menu').find('ul').all('li').count.should == 3 
     # puts find('ul.dropdown-menu').children #.count.should == 2 #have(2).element
      visit admin_room_path(@clone_room)
      click_link 'Supprimer'
      alert = page.driver.browser.switch_to.alert 
      alert.accept 
      sleep 1
      page.all('#admin_organisms_menu ul li a').should have(1).element
    end
    
    
  end
  
  end
end