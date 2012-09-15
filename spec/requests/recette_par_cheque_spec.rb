# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 


describe 'Recette par chèque' do

  include OrganismFixture

  before(:each) do
    create_user
    create_minimal_organism
    @n = Nature.create!(name: 'Vte Nourriture', period_id: @p.id, :income_outcome=>true)

    login_as('quidam')
    @line = @ib.lines.new
    visit new_book_line_path(@ib)
    fill_in 'line_line_date_picker', :with=>'01/04/2012' 
    fill_in 'line_narration', :with=>'Vente par chèque'
    select 'Vte Nourriture', :for=>'line_nature_id'
    fill_in 'line_credit', with: 50.21
    select 'Chèque'
        
  end

 

 it 'on crée une recette par chèque' do 
   # création du compte remise chèque
   click_button 'Créer'
   Line.count.should == 2 # avec sa contrepartie 
 end

  it 'la deuxième ligne doit avoir le compte 511' do
 
   click_button 'Créer'
   Line.last.account_id.should == @p.rem_check_account.id
  end

 

end
