# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c| 
# c.filter = {:wip=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin bank_accounts 

describe 'vue bank_accounts index' do  
  include OrganismFixtureBis 
  

  before(:each) do
    create_user
    create_organism
    login_as('quidam')
  end

  describe 'new bank_account'  do
    before(:each) do
      visit new_admin_organism_bank_account_path(@o)
    end


    it "affiche la page new" do
      current_url.should match new_admin_organism_bank_account_path(@o)
      page.should have_content("Nouveau compte bancaire")
      all('form div.control-group').should have(5).elements # name, number, nickname et comment et sector
      
    end

    it 'remplir correctement le formulaire cree une nouvelle ligne', wip:true do
      @o.should have(1).bank_accounts
      fill_in 'bank_account[bank_name]', :with=>'Crédit Bancaire'
      fill_in 'bank_account[number]', :with=>'12456321AZ'
      fill_in 'bank_account[nickname]', :with=>'Compte courant'
      click_button "Créer le compte" # le compte'
#      current_url.should match admin_organism_bank_accounts_path(@o)
#      all('tbody tr').should have(2).rows
      @o.should have(2).bank_accounts
    end

    context 'remplir incorrectement le formulaire' do
    it 'test uniqueness organism, name, number' do
      
      fill_in 'bank_account[bank_name]', :with=>@ba.bank_name
      fill_in 'bank_account[number]', :with=>@ba.number
      fill_in 'bank_account[nickname]', :with=>'Compte courant'
      click_button "Créer le compte" # le compte'
      page.should have_content('déjà utilisé')
      @o.should have(1).bank_accounts
    end 

    it  'test presence bank name' do
      visit new_admin_organism_bank_account_path(@o)
      fill_in 'bank_account[bank_name]', :with=>@ba.bank_name
      
      click_button "Créer le compte" # le compte'
      page.should have_content('obligatoire')
    end

    end


  end
 
  describe 'index'    do
    
    
    it 'la vue index est affichée'   do
      visit admin_organism_bank_accounts_path(@o)
      current_url.should match(admin_organism_bank_accounts_path(@o))
    end

   

    it 'on peut le choisir dans la vue index pour le modifier'  do
      visit admin_organism_bank_accounts_path(@o)

      # save_and_open_page
      click_link "icon_modifier_bank_account_#{@ba.id.to_s}"
      # save_and_open_page
      current_url.should match(edit_admin_organism_bank_account_path(@o,@ba)) 
    end

  end

  describe 'edit' do

    it 'On peut changer le nom de la banque et revenir à la vue index' do
      visit edit_admin_organism_bank_account_path(@o, @ba)
      fill_in 'bank_account[bank_name]', :with=>'DebiX'
      click_button 'Enregistrer'
      current_url.should match admin_organism_bank_accounts_path(@o)
      first('tbody tr td').text.should == 'DebiX'

      
    end

  end


end

