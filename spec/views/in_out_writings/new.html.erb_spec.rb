# coding: utf-8

require 'spec_helper'

describe "in_out_writings/new" do
  include JcCapybara


 
let(:o) {stub_model(Organism) }
let(:book) {stub_model(Book) }
let(:n) {stub_model(Nature, name:'nature')}
let(:d) {stub_model(Destination, name:'destination')}

before(:each) do
    assign(:in_out_writing, stub_model(InOutWriting, book_id:1, date:Date.today).as_new_record)
    assign(:line, stub_model(ComptaLine, ref:nil).as_new_record)
    assign(:counter_line, stub_model(ComptaLine).as_new_record)
    assign(:book, stub_model(IncomeBook, :title=>'Recettes'))
    assign(:period, stub_model(Period, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31)) )
    assign(:organism, o)
    
    o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque)) 
   end

  it "renders new line  form" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => book_in_out_writings_path(book), :method => "post" do
      assert_select "input#in_out_writing_date_picker", :name => "in_out_writing[date_picker]"
    end
  end

  it 'give the info in a notice if previous line' do
    @w = mock_model(InOutWriting, book:book, book_id:1, date:Date.today)
    view.stub(:icon_to).and_return('stub icone')
    assign(:previous_line, @pl = stub_model(ComptaLine, id:1, narration:'test',
        book_id:book.id, debit:0, credit:12, line_date:Date.today, nature:n, destination:d))
    @pl.stub(:writing).and_return @w
    @w.stub(:support).and_return('DX')
    @pl.stub(:editable?).and_return(true)
    render
    rendered.should have_content 'Ligne n°1 créée'
  end

 

  
end

