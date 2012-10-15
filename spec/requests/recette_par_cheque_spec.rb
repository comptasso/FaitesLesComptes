# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')  


RSpec.configure do |c|
 # c.filter = {wip:true}
end

describe 'Recette par chèque' do

  include OrganismFixture

  before(:each) do
    create_user
    create_minimal_organism
    Nature.create!(name: 'Vte Nourriture', period_id: @p.id, :income_outcome=>true)

    login_as('quidam')
    @w = @ib.writings.new
    @l1 = @w.compta_lines.new
    @l2 = @w.compta_lines.new

    visit new_book_in_out_writing_path(@ib)
    fill_in 'in_out_writing_date_picker', :with=>'01/04/2012'
    fill_in 'in_out_writing_narration', :with=>'Vente par chèque'
    select 'Vte Nourriture', :for=>'in_out_writing_compta_lines_attributes_0_nature_id'
    fill_in 'in_out_writing_compta_lines_attributes_0_credit', with: 50.21
    select 'Chèque'
    select '511 Chèque à encaisser', :for=>'in_out_writing_compta_lines_attributes_1_nature_id'
  end

 

 it 'on crée une recette par chèque' , wip:true do
   # création du compte remise chèque
   save_and_open_page
   click_button 'Créer'
   Writing.count.should == 1
   ComptaLine.count.should == 2 # avec sa contrepartie
 end

  it 'la deuxième ligne doit avoir le compte 511' do
 
   click_button 'Créer'
   ComptaLine.last.account_id.should == @p.rem_check_account.id
  end

 

end
