# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe 'admin/books/new' do
  before(:each) do
    assign(:organism, stub_model(Organism))
    @book = stub_model(Book).as_new_record
  end

  context 'mise en page générale' do
    before(:each) do
      render
    end

    it "should have title h3" do
      rendered.should have_selector('h3') do |h3| 
        h3.should contain "Création d'un livre" 
      end
    end

    it "should have one form" do
      rendered.should have_selector('form', :count=>1)
    end

    it "form should have field title" do
      rendered.should have_selector('form') do |form|
        form.should have_selector('input', :name=>'book[title]')
      end
    end

    it "form should have field description" do
      rendered.should have_selector('form') do |form|
        form.should have_selector('textarea', :name=>'book[description]')
      end
    end

    it "form should have two radio buttons" do
      rendered.should have_selector('form') do |form|
        form.should have_selector('input' ,:name=>'book[book_type]', :count=> 2 )
      end
    end

    it "form should have submit button" do
      rendered.should have_selector('form') do |form|
        form.should have_selector('input' ,:type=>'submit', :value=>'Créer le livre')
      end
    end
 
    
  end
 
      
end

