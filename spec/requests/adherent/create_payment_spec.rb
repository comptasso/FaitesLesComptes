# coding: utf-8

require 'spec_helper'

RSpec.configure do |c| 
 # c.filter = {:wip=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin bank_accounts 

describe 'enregistrement d un payment' do  
  include OrganismFixtureBis
  

  before(:each) do
    create_user
    create_organism
    login_as('quidam')
    
  end
  
  it 'Enregistrer un payment' 
  
end