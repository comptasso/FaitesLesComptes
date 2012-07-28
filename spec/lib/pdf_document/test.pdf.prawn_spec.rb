# coding: utf-8


require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'pdf_document/base'
require 'pdf_document/page'
require 'pdf_document/table'




describe 'test pdf prawn' do  
  include OrganismFixture
   before(:each) do
     create_minimal_organism
     @account =  @p.accounts.create!(number:'60', title:'Achats')
    # on relie la nature @n au compte
     @n.account_id = @account.id
     @n.save!
     # on crée 50 lignes de dépenses
     1.upto(50) do |i|
     l =   Line.new(line_date:Date.today, book_id:@ob.id, narration:'Essai',
     nature_id:@n.id, debit:(i/2.0), cash_id:@c.id, payment_mode:'Espèces')
   if l.valid?
     l.save!
   else
     puts l.errors.messages
   end
     end
   end

#  it 'l valid' do
#    @l.valid?
#    puts @l.errors.messages
#    @l.save!
#  end

  it 'account should have 1 line' do
    @account.should have(50).lines
  end

  it 'should be able to create a pdf document' do
    @pdf = PdfDocument::Base.new(@p, @account, title:@o.title, subtitle:'Essai')
    @pdf.should be_an_instance_of(PdfDocument::Base)
  end

  context 'le document est créé' do
    before(:each) do
      @pdf = PdfDocument::Base.new(@p, @account, title:@o.title, subtitle:'Essai')    
      @pdf.set_columns %w(line_date nature_id debit credit)
      @pdf.set_columns_titles %w(Date Nature Débit Crédit)
      
      @pdf.set_columns_methods [nil, 'nature.name', nil, nil]  
      @pdf.set_columns_widths [10,60,15,15]
      @pdf.set_columns_to_totalize [2,3]
    end 

    it 'should have 3 pages' do 
      @pdf.nb_pages.should == 3  
    end

    it 'pdf page table' do
     puts  @pdf.page(1).table_title 
    end

    it 'largeur des titres' do
      @pdf.page(1).total_columns_widths.should == [70,15,15]
    end

    it 'peut rendre le fichier test.pdf.prawn' do
      @pdf.render('test.pdf.prawn').should be_an_instance_of(File)  
    end

  end

end