# To change this template, choose Tools | Templates
# and open the template in the editor.

# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper') 

describe Compta::GeneralBook do
include OrganismFixtureBis

  before(:each) do
    use_test_organism 
  end

  describe 'GeneralBook peut exister' do 

  before(:each) do
    
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

  describe 'GeneralBook to pdf a autant de pages que de comptes' do 

  it 'test du nombre de page' do
    create_in_out_writing
    @general_book = Compta::GeneralBook.new(period_id:@p.id).with_default_values
    @general_book.send(:to_pdf).page_count.should == 2
    # Les deux pages correspondant aux comptes de l'écriture
  end
  end
end

