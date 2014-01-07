# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c| 
 # c.filter = {:wip=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin bank_accounts 

describe 'vue bank_accounts index' do  
  include OrganismFixtureBis
  
#  def set_host (host)
#  host! host
#  Capybara.server_port = 31234
#  Capybara.app_host = "http://" + host
#end


  before(:each) do
#    Capybara.current_session.driver.reset!
#    set_host "localhost:31234"
    clean_main_base
    create_user
    clean_assotest1
    create_organism
    get_organism_instances
    login_as('quidam')
  end

#  after(:each) do
#    Apartment::Database.switch()
#  end

 
 
  describe 'index'    do
#    it 'test du user', wip:true do
#      puts User.first.inspect
#      puts Room.first.inspect
#
#    end
    
    it 'la vue index est affichée'  do
      # Apartment::Database.switch('assotest1')
      visit admin_organism_bank_accounts_path(@o)
      current_url.should match(admin_organism_bank_accounts_path(@o))
    end

 
  end

 

end

