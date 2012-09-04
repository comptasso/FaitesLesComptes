# coding: utf-8

require 'spec_helper' 

describe "lines/new" do 
  include JcCapybara


 
  let(:o) {stub_model(Organism) }
  let(:book) {stub_model(Book) }
  let(:n) {stub_model(Nature, name:'nature')}
  let(:d) {stub_model(Destination, name:'destination')}
  let(:acc) {stub_model(Account, accountable:mock_model(BankAccount, acronym:'DX 125'))}

  before(:each) do

    assign(:line, stub_model(Line,
        :line_date => Date.today, ref:nil
      ).as_new_record)
    assign(:book, stub_model(OdBook, :title=>'Opérations diverses'))
    assign(:period, stub_model(Period, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31)) )
    assign(:organism, o)
    
    o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque)) 
  end

  it "renders new line  form" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => od_lines_path(book), :method => "post" do
      assert_select "input#line_line_date_picker", :name => "line[line_date_picker]"
    end
  end

  it 'give the info in a notice if previous line' do
    view.stub(:icon_to).and_return('stub icone')
    assign(:previous_line, stub_model(Line, id:1, narration:'test',
        book_id:book.id, debit:0, credit:12, line_date:Date.today, nature:n, destination:d, counter_account:acc))
    render
    rendered.should have_content 'Ligne n°1 créée'
  end

 

  
end

