# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 


 # ActiveRecord::Base.shared_connection = nil

RSpec.configure do |c| 
#  c.filter = {wip:true} 
# c.filter = {:js=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin books   

describe 'books' do  

 
  include OrganismFixtureBis

   before(:each) do
    create_user
    create_minimal_organism 
    login_as('quidam')
  end
    

  describe 'new book' do
    
    it "affiche la page new" , wip:true do
      visit new_admin_organism_book_path(@o)
      page.should have_content("Création d'un livre") 
      page.should have_content('Type')
    
    end

    it 'remplir correctement le formulaire crée un nouveau livre' do
      visit new_admin_organism_book_path(@o)
      fill_in 'book[abbreviation]', with:'RE'
      fill_in 'book[title]', :with=>'Recettes test'
      fill_in 'book[description]', :with=>'Un deuxième livre de recettes'
      choose 'Recettes'
      click_button 'Créer le livre'
      @o.books.count.should == 5
      @o.books.last.book_type.should == 'IncomeBook'
    end

  end
 
  describe 'index' do
    
     it 'dans la vue index,un livre peut être détruit' , :js=>true do
      @o.income_books.create!(:title=>'livre de test', :abbreviation=>'TE')
      @o.books(true).should have(5).elements
      # à ce stade chacun des livres est vierge et peut donc être détruit
      # sauf le Od_Book ni le An_Book
      visit admin_organism_books_path(@o)
      
      within 'tr', text:'livre de test' do       
        click_link 'Supprimer'
      end

      alert = page.driver.browser.switch_to.alert 
      alert.accept 
      sleep 1
      
      @o.books(true).should have(4).elements
     end


    it 'on peut le choisir dans la vue index pour le modifier' do
      visit admin_organism_books_path(@o)
      click_link "icon_modifier_book_#{@ob.id.to_s}"
      page.should have_content("Modification d'un livre") 
    end

  end

  describe 'edition , du titre', wip:true do 
    
    before(:each) do
      @bfid = @o.books.first.id
      visit edit_admin_organism_book_path(@o, @bfid)
      fill_in 'book[title]', :with=>'modif du titre'
      click_button 'Modifier ce livre'
    end

    
    it 'le titre est changé' do
      Book.find(@bfid).title.should == 'modif du titre'
    end
    
     it 'et l on revient à la vue index' do
      current_url.should match /\/admin\/organisms\/#{@o.id}\/books$/
    end

  end


end

