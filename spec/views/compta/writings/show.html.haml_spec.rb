require 'spec_helper'

describe "compta/writings/show" do
  before(:each) do
    @writing = assign(:writing, stub_model(Writing, date:Date.today, narration:'spec', ref:'Bonjour'))
    @book = assign(:book, stub_model(Book))
  end

  it "renders attributes" do 
    render
  end
end
