require 'spec_helper'

describe "compta/writings/show" do
  before(:each) do
    assign(:writing, stub_model(Writing, date:Date.today, narration:'spec', ref:'Bonjour'))
    assign(:book, stub_model(Book))
    assign(:period, stub_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year))
  end

  it "renders attributes" do 
    render
  end
end
