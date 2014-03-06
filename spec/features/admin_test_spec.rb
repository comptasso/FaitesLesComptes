# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c| 
 # c.filter = {:wip=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin bank_accounts 

describe 'Features : vue bank_accounts index' do  
  include OrganismFixtureBis


  before(:each) do
    create_organism
    login_as('quidam')
  end


  describe 'index'    do
    
    it 'la vue index est affichée'  do
      visit admin_organism_bank_accounts_path(@o)
      current_url.should match(admin_organism_bank_accounts_path(@o))
    end
 
  end

 

end

