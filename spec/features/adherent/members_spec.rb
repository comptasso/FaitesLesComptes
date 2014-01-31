# coding: utf-8

require 'spec_helper'

RSpec.configure do |c| 
 # c.filter = {:wip=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin bank_accounts 

describe 'accès au module adhérent' do  
  include OrganismFixtureBis
  

  before(:each) do
    create_user
    create_organism
    login_as('quidam')
    visit admin_organism_path(@o)
  end
  
  it 'on a un lien adherent' do
    page.should have_content('ADHERENTS') 
  end

  it 'cliquer sur ce lien affiche la vue members' do
    click_link 'ADHERENTS'
    page.should have_content('Liste des membres')
  end
  
end