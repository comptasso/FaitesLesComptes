# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {:js=> true }
    c.exclusion_filter = {:js=> true }
end

# spec request for testing admin books

describe 'vue transfer index' do
  include OrganismFixture


  before(:each) do
    clean_test_database
    Transfer.count.should == 0
    create_minimal_organism
    @bb = @o.bank_accounts.create!(:name=>'DebiX', :number=>'123Y')
  end

  it 'check minimal organism' do
    Organism.count.should == 1
    BankAccount.count.should == 2
  end



  describe 'new book' do
    
    it "affiche la page new" do
      visit new_organism_transfer_path(@o)
      page.should have_content("Nouveau virement")
      page.should have_css('form')
    end

    it 'remplir correctement le formulaire crée une nouvelle ligne' do 
      visit new_organism_transfer_path(@o)
      fill_in 'transfer[pick_date]', :with=>'14/04/2012'
      fill_in 'transfer[narration]', :with=>'Premier virement'
      fill_in 'transfer[amount]', :with=>'123.50'
      within('#transfer_fill_debitable') do
        select('DX 123Z')
      end
      within('#transfer_fill_creditable') do
        select('DX 123Y')
      end
      click_button 'Enregistrer'
      @o.transfers.count.should == 1
      # vérification de o
      t= @o.transfers.last
      t.should be_an_instance_of(Transfer)
      t.debitable.should == @ba
      t.creditable.should == @bb
    end

  end
 
  describe 'index' do

    before(:each) do
      # création de deux transfers
      @t1 = @o.transfers.create!(date: Date.today, debitable: @ba, creditable: @bb, amount: 100000, narration: 'création')
      @t2 = @o.transfers.create!(date: Date.today, debitable: @bb, creditable: @ba, amount: 999990, narration: 'inversion')
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
      @t=@o.transfers.create!(:date=>Date.today, :debitable=>@ba, :creditable=>@bb, :amount=>124.12, :narration=>'premier virement')
    end

    it 'On peut changer les deux autres champs' do
      visit edit_organism_transfer_path(@o, @o.transfers.last) 
      fill_in 'transfer[narration]', :with=>'modif du libellé'
      click_button 'Modifier ce virement'
      current_url.should match organism_transfers_path(@o)
    end

  end


end

