# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  # c.filter = {wip:true}
end

describe AnBook do

  let(:p2012) {stub_model(Period, :start_date=>Date.civil(2012,01,01), :close_date=>Date.civil(2012,12,31))}
  let(:o) {stub_model(Organism, :find_period=>p2012)} 

    before(:each) do
      @book = AnBook.new(organism_id:o.id, abbreviation:'AN', title:'A nouveau', description:'Uniquement pour les écritures d\'à nouveau')
      @book.save!
      @book.stub(:organism).and_return(o)
      Writing.any_instance.stub(:book).and_return @book

    end

  def valid_attributes
    {book_id:@book.id, date:p2012.start_date, narration:'A nouveau', :compta_lines_attributes=>{'0'=>{account_id:1, debit:100}, '1'=>{account_id:2, credit:100}}}
  end



  describe 'writing date is start_date' do
    it 'new writing' do
      Writing.any_instance.stub(:previous_period_closed).and_return true
      Writing.new(valid_attributes).should be_valid 
    end

    it 'une autre date que start_date n est pas valide' do
      Writing.any_instance.stub(:previous_period_closed).and_return true
      va = valid_attributes
      va[:date] = Date.today
       Writing.new(va).should_not be_valid
    end

  end

 

end
