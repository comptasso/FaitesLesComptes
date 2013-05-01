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
    @p.natures.create!(name: 'Vte Nourriture', :income_outcome=>true)

    login_as('quidam')  
#    @w = @ib.writings.new
#    @l1 = @w.compta_lines.new
#    @l2 = @w.compta_lines.new

    visit new_book_in_out_writing_path(@ib)
    fill_in 'in_out_writing_date_picker', :with=>I18n::l(Date.today, :foramt=>:date_picker)
    fill_in 'in_out_writing_narration', :with=>'Vente par chèque'
    select 'Vte Nourriture', :for=>'in_out_writing_compta_lines_attributes_0_nature_id'
    fill_in 'in_out_writing_compta_lines_attributes_0_credit', with: 50.21
    select 'Chèque'
    select 'Chèque à encaisser', :for=>'in_out_writing_compta_lines_attributes_1_nature_id'
  end

 it 'verif de l état de la base' do
   
   if Writing.count != 0
     Writing.find_each {|w| puts  w.inspect} 
   end
 end

 it 'on crée une recette par chèque' do
   
   # création du compte remise chèque
   click_button 'Enregistrer'
   Writing.count.should == 1
   ComptaLine.count.should == 2 # avec sa contrepartie
 end

  it 'la deuxième ligne doit avoir le compte 511' do
   click_button 'Enregistrer'
   ComptaLine.last.account_id.should == @p.rem_check_account.id
  end

 

end
