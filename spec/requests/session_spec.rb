# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|  
  #  c.filter = {:js=> true }
  #c.filter = { :wip=>true}
  #  c.exclusion_filter = {:js=> true }
end
 
describe 'Session' do
  include OrganismFixtureBis

  before(:each) do
    clean_main_base
  end

  context 'non logge' do

    it 'non loggé, renvoie sur sign_in'  do
    visit '/admin/rooms'
    page.find('h3').should have_content 'Entrée'
  end
  
    it 'on peut cliquer sur nouvel utilisateur' do
      visit '/'
      click_link("S'enregistrer comme nouvel utilisateur")
      page.find('h3').should have_content 'Création d\'un compte'
    end

  end

  context 'loggé', wip:true  do
   

    it 'sans organisme, renvoie sur la page de création' do
      User.create!(name:'quidam', :email=>'bonjour@example.com', password:'bonjour1' )
      login_as('quidam')
      page.find('h3').should have_content 'Nouvel organisme'
    end

    it 'avec un organisme, renvoie sur le dashboard' do
      create_user
      login_as('quidam')
      page.find('h3').should have_content 'Vous avez 1 message'
    end

    it 'avec plusieures organisme, renvoie sur la liste' do
      create_user
      @cu.rooms.create!(database_name:'assotest2')
      login_as('quidam')
      page.find('h3').should have_content 'Liste des organismes'
    end

  end

  describe 'création d un compte' do

    it 'permet de créer un compte et renvoie sur la page nouvel organisme' do
      visit '/users/sign_up'
      fill_in 'user_name', with:'test'
      fill_in 'user_email', :with=>'test@example.com'
      fill_in 'user_password', :with=>'testtest'
      fill_in 'user_password_confirmation', :with=>'testtest'
      click_button 'S\'inscrire'
      page.find('h3').should have_content 'Nouvel organisme'
    end

  end

  



end
