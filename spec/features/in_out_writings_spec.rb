# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {wip:true}
end

describe 'vue lines' do
  include OrganismFixtureBis

  def nature_name
    @p.natures.depenses.first.name
  end

  before(:each) do
    use_test_user
    login_as(@cu, 'MonkeyMocha')
    use_test_organism
  end

  after(:each) do
    Writing.delete_all
    ComptaLine.delete_all
  end

  describe 'new in_out_writing' do

    before(:each) do
      visit organism_path(@o)
    end

    it "affiche la page new" do
      visit new_book_in_out_writing_path(@ob)
      page.should have_content('nouvelle ligne')
    end

    it 'remplir correctement le formulaire crée une nouvelle ligne', wip:true do
      visit new_book_in_out_writing_path(@ob)

      fill_in 'in_out_writing_date_picker', :with=>I18n::l(Date.today, :format=>:date_picker)
      fill_in 'in_out_writing_narration', :with=>'Ecriture test'
      select nature_name, :from=>'in_out_writing_compta_lines_attributes_0_nature_id'
      fill_in 'in_out_writing_compta_lines_attributes_0_debit', with: 50.21
      select 'Virement'
      select 'Compte courant'
      click_button 'Enregistrer'
      Writing.count.should == 1
      ComptaLine.count.should == 2 # avec sa contrepartie
    end

    it 'remplir avec une mauvaise date doit réafficher le formulaire sans enregistrer la ligne' do
      visit new_book_in_out_writing_path(@ob)

      fill_in 'in_out_writing_date_picker', :with=>'01/04/2012'
      fill_in 'in_out_writing_narration', :with=>'Ecriture test'
      select nature_name, :from=>'in_out_writing_compta_lines_attributes_0_nature_id'
      fill_in 'in_out_writing_compta_lines_attributes_0_debit', with: 50.21
      select 'Chèque'
      click_button 'Enregistrer'
      ComptaLine.count.should == 0
      page.should have_content('nouvelle ligne')
    end

    it 'cliquer sans remplir doit réafficher la page' do
      visit new_book_in_out_writing_path(@ob)
      click_button 'Enregistrer'
      page.should have_content('nouvelle ligne')
    end




  end
end

