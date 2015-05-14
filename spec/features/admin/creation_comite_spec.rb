# coding: utf-8

require 'spec_helper'  

RSpec.configure do |c|
  # c.filter = {wip:true} 
end

describe "creation d un comité" do   
   
  include OrganismFixtureBis
  
  describe 'Création d un premier organisme' do
  
    before(:each) do
      create_only_user
      login_as('quidam')
    end
    
    after(:each) do
      clean_main_base
    end
  
    context 'quand je remplis le formulaire' do
           
      before(:each) do 
        visit new_admin_room_path
        fill_in 'room_title', with:'Mon comité'
        fill_in 'room_comment', with:'Une première'
        fill_in 'room_racine', with:'assotest'
        fill_in 'room_siren', with:'123455666' 
        choose 'Comité d\'entreprise'
      end
      
      after(:each) do
        Room.order('created_at ASC').last.destroy if Room.count > 1
      end
    
      it 'cliquer sur le bouton crée un organisme'  do
        expect {click_button 'Créer l\'organisme'}.to change {Room.count}.by(1)
      end
      
      it 'on est sur la page de création d un exercice' do
        click_button 'Créer l\'organisme'
        page.find('h3').should have_content 'Nouvel exercice' 
      end
      
      describe 'la création de l exercice' do
        
        before(:each) do
          click_button 'Créer l\'organisme'
          click_button 'Créer l\'exercice'
          @o = Organism.first
        end 
      
        it 'ce comité a trois secteurs' do
          expect(@o.sectors.count).to eq(3)
        end
      
        it 'et 4 livres + OD + AN' do
          expect(@o.books.count).to eq(6)
        end
      
      end
            
    end
  end
end