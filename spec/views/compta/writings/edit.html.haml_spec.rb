require 'spec_helper'

describe "compta/writings/edit" do 
  before(:each) do
    assign(:writing, @w = stub_model(Writing))
    assign(:book, @b=stub_model(Book))
    assign(:period, stub_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year))
  end

  it "renders the edit writing form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => compta_book_writings_path(@b, @w), :method => "post" do
    end
  end
end
