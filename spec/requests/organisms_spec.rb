# coding: utf-8 

# TODO ceci devrait devenir un request spec pour Devise

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "vue organisme"  do 
  include OrganismFixtureBis 

  before(:each) do
    clean_main_base
  end

  context 'sans organisme' do

    it 'est dirigé vers la création d un organisme' do
      User.create!(name:'quidam', :email=>'bonjour@example.com', password:'bonjour1' )
      login_as('quidam')
      current_path.should == new_admin_room_path  
    end

  end


  context 'avec un organisme' do  

    before(:each) do
      create_user
      create_minimal_organism 
      login_as('quidam')
    end

    it 'should show organism' do
      page.find('h3').should have_content 'Vous avez 1 message'
      current_path.should == organism_path(@o)
    end

  end

  # TODO tester les fonctionnalités des graphiques

  context 'avec plusieurs organismes' do

    it 'est redirigé vers la vue index' do
      create_user
      create_minimal_organism
      @cu.rooms.create!(database_name:'assotest2')
      login_as('quidam')
      current_path.should == admin_rooms_path 
    end

  end


  
  
end


