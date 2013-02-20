# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|
#  c.filter = {wip:true}
end

describe 'vue lines' do
  include OrganismFixture
   
  before(:each) do
    create_user 
    create_minimal_organism 
    login_as('quidam')

  end

#  it 'test' , wip:true do
#    puts @ba.inspect
#    @ba.name.should == 'DebiX'
#    @p.bank_accounts.first.accountable.name.should == 'DebiX'
#    @p.bank_accounts.first.long_name.should == 'bonjour'
#  end

  describe 'new in_out_writing' do
  
  before(:each) do
    visit organism_path(@p)
  end 

  it "affiche la page new" do
    
    visit new_book_in_out_writing_path(@ob)
    page.should have_content('nouvelle ligne') 
    Writing.count.should == 0
  end

  it 'remplir correctement le formulaire crée une nouvelle ligne' do 
    visit new_book_in_out_writing_path(@ob)
   
    fill_in 'in_out_writing_date_picker', :with=>I18n::l(Date.today, :format=>:date_picker)
    fill_in 'in_out_writing_narration', :with=>'Ecriture test'
    select 'Essai', :for=>'in_out_writing_compta_lines_attributes_0_nature_id'
    fill_in 'in_out_writing_compta_lines_attributes_0_debit', with: 50.21
    select 'Virement'
    select 'Compte courant'
    click_button 'Créer'
    Writing.count.should == 1
    ComptaLine.count.should == 2 # avec sa contrepartie
  end 

    it 'remplir avec une mauvaise date doit réafficher le formulaire sans enregistrer la ligne' do
      visit new_book_in_out_writing_path(@ob)
    
    fill_in 'in_out_writing_date_picker', :with=>'01/04/2012'
    fill_in 'in_out_writing_narration', :with=>'Ecriture test'
    select 'Essai', :for=>'in_out_writing_compta_lines_attributes_0_nature_id'
    fill_in 'in_out_writing_compta_lines_attributes_0_debit', with: 50.21
    select 'Chèque'
    click_button 'Créer'
    ComptaLine.count.should == 0
    page.should have_content('nouvelle ligne')
    end


 

  end
end

