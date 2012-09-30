require 'spec_helper'

describe "compta/writings/index" do
  before(:each) do
    assign(:book, @b=stub_model(Book))
    assign(:period, stub_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year))
    assign(:writings, [
      stub_model(Writing, date:Date.today),
      stub_model(Writing, date:Date.today)
    ])
  end

  it "renders a list of writings" do 
    render
  end
end
