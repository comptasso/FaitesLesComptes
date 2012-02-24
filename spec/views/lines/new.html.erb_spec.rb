# coding: utf-8

require 'spec_helper'

describe "lines/new.html.erb" do

let(:o) {stub_model(Organism) }
let(:book) {stub_model(Book) }

before(:each) do


#    @p=Period.create!(:organism_id=>@o.id, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))
#
#
#  @p.should be_an_instance_of(Period)
#  @p.start_date.should == Date.civil(2012,01,01)
  
    assign(:line, stub_model(Line,
      :line_date => Date.today
    ).as_new_record)
    assign(:book, stub_model(IncomeBook, :title=>'Recettes'))
    assign(:period, stub_model(Period, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31)) )
    assign(:organism, stub_model(Organism))
    assign(:organism, o)
    
    o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque))
   end

  it "renders new line  form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => book_lines_path(book), :method => "post" do
      assert_select "input#pick_date_line", :name => "pick_date_line"
    end
  end
end

