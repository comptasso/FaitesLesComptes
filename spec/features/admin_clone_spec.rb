# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#RSpec.configure do |c|
  #  c.filter = {:js=> true }
  # c.filter = { :wip=>true}
  #  c.exclusion_filter = {:js=> true }  
#end


describe 'resquest clone' do 
  include OrganismFixtureBis

  before(:each) do
    use_test_user 
    login_as('quidam')
    use_test_organism 
    visit admin_room_path(@r)
  end
  
  after(:each) do
    # on efface toutes les rooms autres que celle d'origine
    Room.all.reject {|r| r.id == @r.id}.each {|r| r.destroy} 
  end


  describe 'create clone' do 

    it 'afficher la vue de organisme puis cliquer sur l icone sauvegarder renvoie sur la vue new clone'  do
      click_link("Fait un clone de l'organisme")
      page.find('.champ h3').should have_content "Cloner une base de données : ajouter un commentaire"
      current_url.should match new_admin_clone_path
    end

    it 'remplir la vue et cliquer sur le bouton crée une nouvelle base', js:true do
      nb_rooms = @cu.rooms.count
      visit new_admin_clone_path
      fill_in 'organism[comment]', :with=>'test clonage'
      click_button 'clone_button'
      @cu.rooms(true).count.should == (nb_rooms + 1) 
    end



  end


end
