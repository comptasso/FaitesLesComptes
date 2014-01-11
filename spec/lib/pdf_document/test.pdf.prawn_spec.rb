# coding: utf-8


require 'spec_helper'
require 'pdf_document/default' 
require 'pdf_document/page'
require 'pdf_document/table'  

describe 'test pdf prawn' do    
  include OrganismFixtureBis
   before(:each) do
     create_minimal_organism
     @account =  @p.accounts.find_by_number('60') 
    # on relie la nature @n au compte
     @n.account_id = @account.id 
     @n.save!
     # on crée 50 lignes de dépenses
     1.upto(50) do |i|
        create_outcome_writing(i) 
     end
 
   end

#  it 'l valid' do
#    @l.valid?
#    puts @l.errors.messages
#    @l.save!
#  end

  it 'account should have 1 line' do
    @account.should have(50).compta_lines
  end

  it 'should be able to create a pdf document' do
    @pdf = PdfDocument::Default.new(@p, @account, title:@o.title, subtitle:'Essai')
    @pdf.should be_an_instance_of(PdfDocument::Default)
  end

  context 'le document est créé' do
    before(:each) do
      @pdf = PdfDocument::Default.new(@p, @account, title:@o.title, subtitle:'Essai')
      @pdf.columns_select =  ['writings.date AS w_date', 'nature_id', 'debit', 'credit']
      @pdf.columns_titles = %w(Date Nature Débit Crédit)
      
      @pdf.columns_methods = ['w_date', 'nature.name', nil, nil]
      @pdf.columns_widths = [10,60,15,15]
      @pdf.columns_to_totalize = [2,3]
    end 

    it 'should have 3 pages' do 
      @pdf.nb_pages.should == 3  
    end

    it 'largeur des titres' do
      @pdf.page(1).total_columns_widths.should == [70,15,15]
    end

    it 'peut rendre le fichier test.pdf.prawn' do
     # pending 'ce n est plus un file mais un flux'
      @pdf.render.should be_an_instance_of(String)
    end

  end

end