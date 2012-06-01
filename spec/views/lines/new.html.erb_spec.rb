# coding: utf-8

require 'spec_helper'

describe "lines/new" do 
 
let(:o) {stub_model(Organism) }
let(:book) {stub_model(Book) }
let(:n) {stub_model(Nature, name:'nature')}
let(:d) {stub_model(Destination, name:'destination')}

before(:each) do

    assign(:line, stub_model(Line,
      :line_date => Date.today, ref:nil
    ).as_new_record)
    assign(:book, stub_model(IncomeBook, :title=>'Recettes'))
    assign(:period, stub_model(Period, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31)) )
    assign(:organism, o)
    
    o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque)) 
   end

  it "renders new line  form" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => book_lines_path(book), :method => "post" do
      assert_select "input#line_pick_date", :name => "line[pick_date]"
    end
  end

  it 'give the info in a notice if previous line' do

    pending
    assign(:previous_line, stub_model(Line, id:1, narration:'test',
        book_id:book.id, debit:0, credit:12, line_date:Date.today, nature:n, destination:d))
    render
    page.should have_content 'Ligne n°1 créée'
  end

  it 'shows the required mark for 5 fields' do
    pending
    render
    response.should contain('*', count: 5) 
  end
end

