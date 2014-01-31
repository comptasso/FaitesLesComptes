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
   
    visit new_mask_writing_path(@mask) 
  end
  
  it 'la page affiche le titre' do
    page.find('h3').text.should == "Recettes : nouvelle ligne"
  end
  
  it 'le formulaire est affiché' do
     page.all('form').should have(1).element
     page.find('#in_out_writing_narration').value.should == 'Facture régulière'
      page.find('#in_out_writing_compta_lines_attributes_0_nature_id option[selected]').text.should =='Prestations de services'
      page.find('#in_out_writing_compta_lines_attributes_1_payment_mode option[selected]').value.should == 'CB'
      page.find('#in_out_writing_compta_lines_attributes_0_credit').value.should == '111.11'
  end
  
  it 'compléter le formulaire et valider crée une écriture' do
    select 'Non affecté'
    select 'Compte courant'
    expect {click_button('Enregistrer')}.to change {InOutWriting.count}.by(1)
  end
    
    
    
  end
