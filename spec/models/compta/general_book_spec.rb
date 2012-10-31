# To change this template, choose Tools | Templates
# and open the template in the editor.

# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')  

describe Compta::GeneralBook do

  before(:each) do
    @o=Organism.create!(title:'test balance sans table', database_name:'assotest1')
    @p= Period.create!(organism_id:@o.id, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
    @a1 = @p.accounts.find_by_number('60')
    @a2 = @p.accounts.find_by_number('701')
    @general_book = Compta::GeneralBook.new(period_id:@p.id).with_default_values
  end

  it "should exist" do
   @general_book.should be_an_instance_of(Compta::GeneralBook)
  end

  it 'and render pdf' do
    @general_book.render_pdf.should be_an_instance_of String
  end
  
end

