require 'spec_helper'

RSpec.configure do |c|
  # c.filter = {wip:true}
end

include OrganismFixtureBis

describe 'création d une écriture à partir d un guide' do
  
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
    @mask = @o.masks.create!(valid_attributes)
    visit new_mask_writing_mask_path(@mask)
  end
  
  it 'la page affiche le titre' do
    page.find('h3').text.should == 'saisie d une nouvelle écriture'
  end
  
  it 'le formulaire est affiché'


    
   
    
    
    
  end
