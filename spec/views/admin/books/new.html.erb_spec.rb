# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/books/new' do
  include JcCapybara
  before(:each) do
    assign(:organism, stub_model(Organism))
    @book = stub_model(Book).as_new_record
  end

  context 'mise en page générale' do
    before(:each) do
      render
    end

    it "should have title h3" do
      page.find('h3').text.should ==  "Création d'un livre"
      
    end

    it "should have one form" do
      page.all('form').should have(1).element
    end

    it "form should have field title" do
      page.should have_css('form input[name="book[title]"]')
    end

    it "form should have field title" do
      page.should have_css('form textarea[name="book[description]"]')
    end

    it "form should have field title" do
      page.all('form input[name="book[book_type]"]').should have(2).elements
    end

    it "form should have field title" do
      page.find('form input[type="submit"]').value.should == 'Créer le livre'
    end

    
  end
 
      
end

