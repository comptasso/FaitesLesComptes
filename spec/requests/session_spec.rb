# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {:js=> true }
  # c.filter = { :wip=>true}
  #  c.exclusion_filter = {:js=> true }
end
 
describe 'Session' do


  it 'permet de se logguer' do
    visit '/'
    page.all('form').count.should == 1 
  end

  it 'remplissage du formulaire' do
    visit '/'
    fill_in 'name', :with=>'inconnu'
    click_button('Entrée')
    page.should have_content 'Cet utilisateur est inconnu'
  end

  it 'création d un nouvel utilisateur' do
    visit '/'
    fill_in 'name', :with=>'Paul'
    click_button('Entrée')
    click_link 'Nouvel utilisateur' 
    fill_in 'user_name', :with=>'Paul'
    click_button 'Create User'
    page.should have_content 'Nouvel organisme' 
  end



end
