require 'spec_helper'

describe "compta/writings/new" do
  before(:each) do
    assign(:writing, stub_model(Writing).as_new_record)
    assign(:book, @b=stub_model(Book))
    assign(:period, stub_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year))
  end

  it "renders new writing form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => compta_book_writings_path(@b), :method => "post" do
    end
  end
end
