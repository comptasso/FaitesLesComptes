# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OdLinesController do
  include SpecControllerHelper 

  before(:each) do
    minimal_instances
    @od_book = mock_model(Book)
    @p.stub(:all_natures_linked_to_account?).and_return true
    Book.stub(:find_by_type).with('OdBook').and_return(@od_book)
    @p.stub(:natures).and_return [1,2]
    @od_book.stub_chain(:lines, :new).and_return(mock_model(Line).as_new_record) 

  end

  describe "GET new" do
    it "assigns a new balance" do
      get :new, {}, valid_session
      response.should render_template :new
    end


  end

end
