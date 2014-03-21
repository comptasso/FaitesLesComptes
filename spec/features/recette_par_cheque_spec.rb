# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')  


RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe 'Recette par chèque' do  

  include OrganismFixtureBis 

  before(:each) do
    use_test_user
    login_as('quidam')
    use_test_organism 
    @nature_name = @p.natures.recettes.first.name
    

    visit new_book_in_out_writing_path(@ib)
    fill_in 'in_out_writing_date_picker', :with=>I18n::l(Date.today, :foramt=>:date_picker)
    fill_in 'in_out_writing_narration', :with=>'Vente par chèque'
    select @nature_name, :from=>'in_out_writing_compta_lines_attributes_0_nature_id'
    fill_in 'in_out_writing_compta_lines_attributes_0_credit', with: 50.21
    select 'Chèque'
  
  end
  
  after(:each) do
    Writing.delete_all
    ComptaLine.delete_all
  end

 
  it 'on crée une recette par chèque', wip:true do
    select 'Chèques à l\'encaissement', :from=>'in_out_writing_compta_lines_attributes_1_account_id'
    click_button 'Enregistrer'
    Writing.count.should == 1
    ComptaLine.count.should == 2 # avec sa contrepartie
  end

  it 'la deuxième ligne doit avoir le compte 511' do
    select 'Chèques à l\'encaissement', :from=>'in_out_writing_compta_lines_attributes_1_account_id'
    click_button 'Enregistrer'
    ComptaLine.last.account_id.should == @p.rem_check_account.id
  end

 

end
