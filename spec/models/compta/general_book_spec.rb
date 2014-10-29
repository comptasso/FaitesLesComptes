# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper') 

describe Compta::GeneralBook do
  include OrganismFixtureBis

  before(:each) do
    use_test_organism 
  end

  describe 'GeneralBook'  do

    before(:each) do 
      @general_book = Compta::GeneralBook.new(period_id:@p.id).with_default_values
    end

    it "peut se créer avec un exercice et des valeurs par défaut" do
      @general_book.should be_an_instance_of(Compta::GeneralBook) 
    end

    it 'sait rendre un pdf' do
      @general_book.render_pdf.should be_an_instance_of String
    end

    it 'qui contient au moins autant de pages que de comptes' do
      @general_book.to_pdf.page_count.should >= @p.accounts.count
    end
  
  end

end
