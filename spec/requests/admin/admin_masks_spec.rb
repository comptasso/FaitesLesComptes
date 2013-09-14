require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe "admin mask" do
  
  include OrganismFixtureBis
  
  def valid_attributes 
    { 
      title:'Le titre du masque',
      comment:'Un commentaire',
      nature_name:@nat.name,
      book_id:@o.income_books.first.id,
      narration:'Facture régulière', 
      mode:'CB',
      amount:'111.11'
      
    }
  end
  
  before(:each) do
    create_user
    create_minimal_organism 
    login_as('quidam')
    @nat = @p.natures.recettes.first
  end
  
  
  describe "EDIT /admin_masks" do
    
    before(:each) do
      @mask = @o.masks.create!(valid_attributes)
      visit edit_admin_organism_mask_path(@o, @mask)
    end
    
    it "affiche le titre" do
      page.find('h3').text.should == 'Modification d\'un masque de saisie'
    end
    
    it 'affiche le formulaire' do
     
     page.all('form').should have(1).element
    end
    
    it 'avec les informations pré remplies' do
      page.find('#mask_narration').value.should == 'Facture régulière'
      page.find('#mask_nature_name option[selected]').value.should =='Prestations de services'
      page.find('#mask_mode option[selected]').value.should == 'CB'
      page.find('#mask_amount').value.should == '111.11'
      
    end
  end
  
  describe "NEW /admin_masks" , wip:true do
    before(:each) do
      visit new_admin_organism_mask_path(@o)
    end
    
    it 'affiche le formulaire' do
      page.find('h3').text.should == 'Nouveau masque de saisie'
      page.all('form').should have(1).element
    end
    
    it 'remplir le formulaire incorrectement affiche la vue new' do
      fill_in 'mask[narration]', :with=>'a'  # nom trop court
      click_button 'Enregistrer'
      page.should have_content 'Des erreurs ont été trouvées'
    end
    
    it 'remplir le formulaire correctement cree un nouveau masque et renvoie sur la page show' do
      fill_in 'mask[title]', with:'Masque principal'
      select 'Recettes', :from=>'mask[book_id]'
      fill_in 'mask[narration]', with:'Un test de plus'
      fill_in 'mask[amount]', with:56.25
      select 'CB', :from=>'mask[mode]'
      click_button 'Enregistrer'
      page.find('h3').text.should == 'Détail du masque de saisie \'Masque principal\''
    end
    
    
  end
  
  describe 'création d une écriture à partir d un guide' do
    
    before(:each) do
      @mask = @o.masks.create!(valid_attributes)
      visit edit_admin_organism_mask_path(@o, @mask)
    end
    
    
    
  end
end
