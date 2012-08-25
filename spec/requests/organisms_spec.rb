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
     page.find('h3').should have_content 'Description de l\'organisme'
     current_path.should == admin_organism_path(@o)

  end

  end

  context 'sans organisme' do

    before(:each) do
      @cu = User.create!(name:'untel')
    end

    it 'est dirigé vers la création d un organisme' do
      visit '/'
      fill_in 'name', :with=>'untel'
      click_button 'Entrée'
      current_path.should == new_admin_organism_path
    end

  end
end


