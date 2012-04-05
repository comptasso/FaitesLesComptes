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
  end 

  it "affiche la page new" do
    visit new_book_line_path(@ob)
    response.should contain('nouvelle ligne') 
    Line.count.should == 0
  end

  it 'remplir correctement le formulaire crée une nouvelle ligne' do
    visit new_book_line_path(@ob)
    fill_in 'line_pick_date', :with=>'01/04/2012'
    fill_in 'line_narration', :with=>'Ecriture test'
    select 'Essai', :for=>'line_nature_id'
    fill_in 'line_debit', with: 50.21
    select 'Chèque'
    click_button 'Créer'
    assigns[:line].errors.count.should == 0
    assigns[:line].pick_date.should == '01/04/2012'
    Line.count.should == 1  
  end 

    it 'remplir avec une mauvaise date doit réafficher le formulaire sans enregistrer la ligne' do
      visit new_book_line_path(@ob)
    fill_in 'line_pick_date', :with=>'31/04/2012'
    fill_in 'line_narration', :with=>'Ecriture test'
    select 'Essai', :for=>'line_nature_id'
    fill_in 'line_debit', with: 50.21
    select 'Chèque'
    click_button 'Créer'
    Line.count.should == 0
    response.should contain('nouvelle ligne')
    end


 

  end
end

