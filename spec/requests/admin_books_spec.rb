# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
#  c.filter = {:js=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin books

describe 'vue books index' do
  include OrganismFixture


  before(:each) do
    clean_test_database
    Book.count.should == 0
    create_minimal_organism 
  end

  it 'check minimal organism' do
    Organism.count.should == 1
    Book.count.should == 2 
  end



  describe 'new book' do
    
    it "affiche la page new" do
      visit new_admin_organism_book_path(@o)
      page.should have_content("Création d'un livre")
      page.should have_content('Type')
    
    end

    it 'remplir correctement le formulaire crée une nouvelle ligne' do 
      visit new_admin_organism_book_path(@o)
      fill_in 'book[title]', :with=>'Recettes test'
      fill_in 'book[description]', :with=>'Un deuxième livre de recettes'
      choose 'Recettes'
      click_button 'Créer le livre'
      @o.books.count.should == 3
      @o.books.last.book_type.should == 'IncomeBook'
    end

  end
 
  describe 'index' do

    it 'dans la vue index,un livre peut être détruit', :js=>true do
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
      visit admin_organism_books_path(@o)
      click_link "icon_modifier_book_#{@ob.id.to_s}"
      page.should have_content("Modification d'un livre")
    end

  end

  describe 'edit' do

    it 'On peut changer les deux autres champs' do
      visit edit_admin_organism_book_path(@o, @o.books.last)
      fill_in 'book[title]', :with=>'modif du titre'
      click_button 'Modifier ce livre'
      current_url.should match /\/admin\/organisms\/#{@o.id}\/books$/
    end

  end


end

