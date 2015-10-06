# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
#   c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin bank_accounts

describe 'vue bank_accounts index' do
  include OrganismFixtureBis

  describe 'connexion', wip:true do

    before(:each) do

    end

    after(:each) do
      # t = Tenant.find_by_name('FLC Test')
      # t.destroy if t
      # u = User.find_by_name('Alfred')
      # u.destroy if u
    end

    it 'est connecté' do
      visit '/'
      page.should have_content 'Entrée'
    end

    it 'on peut créer un compte' do
      visit 'users/sign_up'
      page.should have_content 'Création d\'un compte'
    end

    it 'on peut créer un compte' do
      visit 'users/sign_up'
      fill_in 'user_name', with: 'Albert'
      fill_in 'user_email', with: 'albert@example.com'
      fill_in 'user_password', with:'faiteslescomptes'
      fill_in 'user_password_confirmation', with:'faiteslescomptes'
      fill_in 'tenant_name', with:'FLC Test'
      expect {click_button "S'inscrire"}.to change {User.count}.by(1)
    end

    it 'on peut aussi se connecter' do
      User.count.should == 4
      visit 'users/sign_in'
      fill_in 'user_email', with:'alfred@example.com'
      fill_in 'user_password', with:'passwOrd'
      click_button 'Valider'
      page.should have_content 'Liste des organismes'
    end

    it 'ou faire comme si on était connecté' do
       use_test_user
       login_as(@cu, 'MonkeyMocha')
       visit admin_organisms_path
       page.should have_content('Liste des organismes')

    end

 end
end




