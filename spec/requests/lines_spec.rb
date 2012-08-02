# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')



describe 'vue lines' do
  include OrganismFixture 
  
  before(:each) do
    create_minimal_organism
  end

  describe 'new line' do 
  
  
  
  before(:each) do
    @line = @ob.lines.new
     visit organism_path(@p)
  end 

  it "affiche la page new" do
    visit organism_path(@p)
    visit new_book_line_path(@ob)
    page.should have_content('nouvelle ligne') 
    Line.count.should == 0
  end

  it 'remplir correctement le formulaire crée une nouvelle ligne' do
    visit new_book_line_path(@ob)
    fill_in 'line_line_date_picker', :with=>'01/04/2012'
    fill_in 'line_narration', :with=>'Ecriture test'
    select 'Essai', :for=>'line_nature_id'
    fill_in 'line_debit', with: 50.21
    select 'Chèque'
    click_button 'Créer'
    Line.count.should == 1  
  end 

    it 'remplir avec une mauvaise date doit réafficher le formulaire sans enregistrer la ligne' do
      visit new_book_line_path(@ob)
    fill_in 'line_line_date_picker', :with=>'31/04/2012'
    fill_in 'line_narration', :with=>'Ecriture test'
    select 'Essai', :for=>'line_nature_id'
    fill_in 'line_debit', with: 50.21
    select 'Chèque'
    click_button 'Créer'
    Line.count.should == 0
    page.should have_content('nouvelle ligne')
    end


 

  end
end

