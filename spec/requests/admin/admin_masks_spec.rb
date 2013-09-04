require 'spec_helper'

describe "admin mask" do
  
  include OrganismFixtureBis
  
  
  before(:each) do
    create_user
    create_minimal_organism 
    login_as('quidam')
    
  end
  
  
  describe "EDIT /admin_masks" do
    
    before(:each) do
      @mask = @o.masks.create(title:'Le titre', comment:'Un commentaire')
    end
    
    it "affiche la vue edit" do
      visit edit_admin_organism_mask_path(@o, @mask)
      page.all('textarea').should have(1).element
    end
    
    it 'teste le status' do
      rendered.status.should =='200'
    end
  end
end
