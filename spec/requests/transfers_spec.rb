# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
#  c.filter = {:js=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin books

describe 'vue transfer index' do
  include OrganismFixture


  before(:each) do
    clean_test_database
    Transfer.count.should == 0
    create_minimal_organism
    @o.bank_accounts.create!(:name=>'beneficiaire', :number=>123)
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
#      fill_in 'book[title]', :with=>'Recettes test'
#      fill_in 'book[description]', :with=>'Un deuxième livre de recettes'
#      choose 'Recettes'
#      click_button 'Créer le livre'
#      @o.books.count.should == 3
#      @o.books.last.book_type.should == 'IncomeBook'
    end

  end
 
  describe 'index' do

   before(:each) do
     visit organism_transfers_path(@o)
   end

    it 'affiche une table avec les virements classés par date'

    it 'dans la vue virement,un virement peut être détruit si ' do
      pending
      @o.income_books.create!(:title=>'livre de test')
      @o.should have(3).books
      # à ce stade chacun des livres est vierge et peut donc être détruit.
      visit admin_organism_books_path(@o)
      within 'tbody tr:nth-child(3)' do
        page.should have_content('livre de test') 
        page.click_link 'Supprimer' 
      end
       alert = page.driver.browser.switch_to.alert 
      alert.accept
      @o.should have(2).books
    end

    it 'on peut le choisir dans la vue index pour le modifier' do
      pending
      visit admin_organism_books_path(@o)
      click_link "icon_modifier_book_#{@ob.id.to_s}"
      page.should have_content("Modification d'un livre")   
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
      current_url.should == organism_transfers_path(@o)
    end

  end


end

