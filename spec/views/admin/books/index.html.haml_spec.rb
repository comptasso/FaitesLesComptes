# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/books/index' do
  include JcCapybara

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
    

    it "should have title h3" do
      render
      page.find('h3').text.should ==  'Liste des livres'
    end

    it "should have one table" do
      render
      page.all('table').should have(1).elements
    end

    it "table body should have two lines" do
      render
      page.all('table tbody tr').should have(2).elements
    end

    it "each row should show 1 icon (edit)" do
      render
      page.find('tbody tr:first').should have_css('img',:count=>1)
    end

    it "each row should show modifier icon" do
      render
      page.all('tbody tr img').first[:src].should match /\/assets\/icones\/modifier.png/
    end

   context 'les titres des colonnes' do
      it "title row should show Titre" do
        render
        page.find('th:first').text.should == 'Abbreviation'
        page.find('th:nth-child(2)').text.should == 'Titre'
        page.find('th:nth-child(3)').text.should == 'Description'
        
        page.find('th:nth-child(4)').text.should == 'Créé le'
        page.find('th:nth-child(5)').text.should == 'Mis à jour le'
       
        page.find('th:nth-child(6)').text.should =='Actions'
      end

    end
  end
  # on ne peut le traiter comme les autres car le render ne doit pas arriver
  # avant le stub_chain
  context 'test de l affichage de l icone destroy' do
    it "with a compta_line, row should not propose supprimer" do
      @books.first.stub_chain(:compta_lines, :empty?).and_return(false)
      render
      page.should_not have_css('tbody tr:first img[src="/assets/icones/supprimer.png"]')
    end
  end 
       
end

