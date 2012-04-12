# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/books/edit' do

  include JcCapybara

  before(:each) do
    assign(:organism, stub_model(Organism))
    @book = stub_model(Book)
  end

  context 'mise en page générale' do
    before(:each) do
      render
    end

    it "should have title h3" do
      page.find('h3').text.should match "Modification d'un livre"

    end

    it "should have one form" do
      page.all('form').should have(1).element
    end

    it "form should have field title" do
      page.should have_css('form input[name="book[title]"]')
    end

    it "form should have field description" do
      page.should have_css('form textarea[name="book[description]"]')
    end

    it "two inputs (radio buttons) are deselected" do
      page.all('form input[disabled="disabled"]').should have(2).elements
    end

    it "form should have field title" do
      page.find('form input[type="submit"]').value.should == 'Modifier ce livre'
    end



 
    
  end
 
      
end

