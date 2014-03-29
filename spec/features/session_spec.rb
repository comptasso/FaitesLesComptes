# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|  
  #  c.filter = {:js=> true }
  #  c.filter = { :wip=>true}
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
    end

  end

  context 'loggé'  do 


    it 'sans organisme, renvoie sur la page de création' do
      create_only_user
      login_as('quidam')
      page.find('h3').should have_content 'Nouvel organisme'
    end 

    it 'avec un organisme, renvoie sur le dashboard' do
      create_user 
      create_organism
      login_as('quidam') 
      current_url.should match /http:\/\/www.example.com\/organisms\/\d*/ 
    end

    it 'avec plusieures organisme, renvoie sur la liste' , wip:true do
      create_user
      create_organism
      # plutôt que de créer réellement plusieurs bases, on fait un stub
      ApplicationController.any_instance.stub(:current_user).and_return @cu
      @cu.stub_chain(:rooms).and_return([@r, @r])
      #@cu.stub(:up_to_date?).and_return true
      login_as('quidam')
      page.find('h3').should have_content 'Liste des organismes'
    end

  end

  describe 'création d un compte' do
    
    after(:each) do
      User.delete_all
    end

    it 'permet de créer un compte et renvoie sur la page merci de votre inscription' do
      visit '/users/sign_up'
      fill_in 'user_name', with:'test'
      fill_in 'user_email', :with=>'test@example.com'
      fill_in 'user_password', :with=>'testtest'
      fill_in 'user_password_confirmation', :with=>'testtest'
      click_button 'S\'inscrire'
      page.find('h3').should have_content 'Merci pour votre inscription et à très bientôt'
    end

    it 'envoie un mail par UserObeserver' do
      UserInscription.should_receive(:new_user_advice).and_return(double(Object, deliver:true ))
      visit '/users/sign_up'
      fill_in 'user_name', with:'test'
      fill_in 'user_email', :with=>'test@example.com'
      fill_in 'user_password', :with=>'testtest'
      fill_in 'user_password_confirmation', :with=>'testtest'
      click_button 'S\'inscrire' 
      
    end 

  end

  



end
