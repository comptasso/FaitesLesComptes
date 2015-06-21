# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper') 

describe Compta::GeneralBook do
  include OrganismFixtureBis 

  before(:each) do
    use_test_organism
    create_outcome_writing
  end
 
  after(:each) do
    Writing.delete_all
    ComptaLine.delete_all
  end
  
  def render_file(pdf, file_name) 
    file =  "#{File.dirname(__FILE__)}/pdf_files/#{file_name}.pdf"
    File.delete(file) if File.exists?(file)
    File.open(file, 'wb') do |f| 
      f << pdf.render 
    end
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

    it 'avec autant de pages que de comptes ayant des mouvements' do
      gb = @general_book.to_pdf
      render_file(gb, 'grand_livre')
      gb.page_count.should == 3 # ici 2 pages car une seule écriture + page de garde
    end
  
  end

end
