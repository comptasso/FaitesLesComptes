# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

RSpec.configure do |c|
  #  c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true } 
end

# spec request for testing admin books 

describe 'vue transfer index' do
  include OrganismFixture 


  before(:each) do 
    create_user 
    create_minimal_organism
    @bb = @o.bank_accounts.create!(:name=>'Deuxième banque', :number=>'123Y')
    @bbca = @bb.current_account(@p) # ca pour Current Account

    login_as('quidam')
  end

  it 'check minimal organism' do
    Organism.count.should == 1
    BankAccount.count.should == 2
    @o.transfers.count.should == 0
  end



  describe 'new transfer' do
    
    it "affiche la page new" do
      visit new_organism_transfer_path(@o)
      page.should have_content("Nouveau virement")
      page.should have_css('form')
    end

    it 'remplir correctement le formulaire crée un nouveau transfert' do
      visit new_organism_transfer_path(@o)
      fill_in 'transfer[date_picker]', :with=>'14/04/2012'
      fill_in 'transfer[narration]', :with=>'Premier virement'
      fill_in 'transfer[amount]', :with=>'123.50'
      within("#transfer_to_account_id optgroup[label='Banques']") do
        select(@ba.accounts.first.long_name)
      end
      within("#transfer_from_account_id optgroup[label='Banques']") do
        select(@bb.accounts.first.long_name)
      end
      click_button 'Enregistrer'
      @o.transfers.count.should == 1
      # vérification de o
      t= @o.transfers.last
      t.should be_an_instance_of(Transfer)
      t.to_account.id.should == @baca.id
      t.from_account.id.should == @bbca.id
    end

    context 'le remplir incorrectement' , wip:true  do

      before(:each) do
      visit new_organism_transfer_path(@o)
      fill_in 'transfer[date_picker]', :with=>'14/04/2012'
      fill_in 'transfer[narration]', :with=>'Premier virement'
      fill_in 'transfer[amount]', :with=>'123.50'
      save_and_open_page
      within('#transfer_to_account_id') do
        select(@ba.accounts.first.long_name)
      end
      within('#transfer_from_account_id') do
        select(@bb.accounts.first.long_name)
      end

      end

      it 'sans montant reaffiche la vue' do
        fill_in 'transfer[amount]', :with=>'bonjour'
        click_button 'Enregistrer'
        page.should have_content 'Nouveau virement'
      end

      it 'affiche des message d erreurs' do
        fill_in 'transfer[amount]', :with=>''
        click_button 'Enregistrer'
        
        page.should have_content 'obligatoire' 
      end
    end

  end
 
  describe 'index' do

    before(:each) do
      # création de deux transfers
      @t1 = @o.transfers.create!(date: Date.today, to_account_id:@baca.id, from_account_id: @bbca.id, amount: 100000, narration: 'création')
      @t2 = @o.transfers.create!(date: Date.today, to_account_id:@bbca.id, from_account_id: @baca.id, amount: 999990, narration: 'inversion')
      visit organism_transfers_path(@o)
    end

    it 'affiche une table avec deux virements' do
      page.should have_css('table tbody')
      page.all('table tbody tr').should have(2).rows
    end

    it 'dans la vue virement,un virement peut être détruit si ', :js=>true do
      # à ce stade aucun virement n'est confirmé et peut être détruit
      within 'tbody tr:nth-child(2)' do
        click_link 'Supprimer' 
      end
      alert = page.driver.browser.switch_to.alert
      alert.accept
      sleep 1
      @o.should have(1).transfers
    end

    it 'on peut le choisir dans la vue index pour le modifier' do
      within 'tbody tr:nth-child(2)' do
        click_link 'Modifier'
      end
      current_url.should match edit_organism_transfer_path(@o,@t2)
    end 

  end

  describe 'edit' do

    before(:each) do
      @bb = @o.bank_accounts.create!(:name=>'DebiX', :number=>'987654')
      @t=@o.transfers.create!(:date=>Date.today, :to_account_id=>@baca.id, :from_account_id=>@bb.accounts.first.id, :amount=>124.12, :narration=>'premier virement')
    end

    it 'On peut changer les deux autres champs' do
      visit edit_organism_transfer_path(@o, @o.transfers.last) 
      fill_in 'transfer[narration]', :with=>'modif du libellé'
      click_button 'Modifier ce virement'
      current_url.should match organism_transfers_path(@o)
    end

  end


end

