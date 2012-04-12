# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/books/index' do
  before(:each) do
    assign(:organism, stub_model(Organism))
    @books=[]
    @books << stub_model(IncomeBook, title: 'Recettes')
    @books << stub_model(OutcomeBook, title: 'Dépenses')
    @books.each do |b|
      b.stub(:created_at).and_return(Time.now)
      b.stub(:updated_at).and_return(Time.now)
    end
  end

  context 'mise en page générale' do
    before(:each) do
      render
    end

    it "should have title h3" do
      rendered.should have_selector('h3') do |h3|
        h3.should contain 'Liste des livres'
      end
    end

    it "should have one table" do
      rendered.should have_selector('table', :count=>1)
    end

    it "table body should have two lines" do
      rendered.should have_selector('table tbody') do |tbody|
        tbody.should have_selector('tr', :count=>2)
      end
    end

    it "each row should show edit icon" do
      rendered.should have_selector('tbody tr') do |row|
        row.should have_selector('img', :src=>'/assets/icones/modifier.png')
      end
    end

    it "each row should show delete icon" do
      rendered.should have_selector('tbody tr') do |row|
        row.should have_selector('img', :src=>'/assets/icones/supprimer.png')
      end
    end

    context 'les titres des colonnes' do
      it "title row should show Titre" do
        rendered.should have_selector('thead tr th') do |cell|
          cell.should contain('Titre' )
        end
      end

      it "title row should show Description" do
        rendered.should have_selector('thead tr th') do |cell|
          cell.should contain('Description' )
        end
      end

      it "title row should show creation date" do
        rendered.should have_selector('thead tr th') do |cell|
          cell.should contain('Créé le' ) 
        end
      end

      it "title row should show update date" do
        rendered.should have_selector('thead tr th') do |cell|
          cell.should contain('Mis à jour le' )
        end
      end

      it "title row should show Actions" do
        rendered.should have_selector('thead tr th') do |cell|
          cell.should contain('Actions' )
        end
      end

      it "title row should show book type" do
        rendered.should have_selector('thead tr th') do |cell|
          cell.should contain('Type de livre' )
        end
      end
    end
 end
   # on ne peut le traiter comme les autres car le render ne doit pas arriver
  # avant le stub_chain
  context 'test de l affichage de l icone destroy' do
    it "with a line, row should not propose supprimer" do
      @books.first.stub_chain(:lines, :empty?).and_return(false)
      render
      rendered.should have_selector('tbody tr:first-child') do |row|
        row.should_not have_selector('img', :src=>"/assets/icones/supprimer.png")
      end
    end
  end 
      
end

