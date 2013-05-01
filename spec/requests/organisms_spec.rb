# coding: utf-8 

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "vue organisme"  do
  include OrganismFixture

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

  context 'avec plusieurs organismes' do

    it 'est redirigé vers la vue index' do
      create_user
      create_minimal_organism
      create_second_organism
      login_as('quidam')
      current_path.should == admin_rooms_path 
    end

  end


  context 'sans organisme' do

    before(:each) do
      @cu = User.create!(name:'untel')
    end

    it 'est dirigé vers la création d un organisme' do
      visit '/'
      fill_in 'user_name', :with=>'untel'
      click_button 'Entrée'
      current_path.should == new_admin_room_path
    end

  end

  
end


