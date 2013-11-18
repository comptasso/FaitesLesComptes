# coding: utf-8

require 'spec_helper'
require 'pdf_document/base.rb'
require 'pdf_document/page'
require 'pdf_document/base_prawn'

describe PdfDocument::Base do
  
  let(:obj) {double(Object, name:'BOURDON', forname:'Jean')}
  
  def valid_collection
    100.times.collect {|i| obj}
  end
  
  def valid_options
    {title:'Ma spec', columns_methods:['name', 'forname']}
  end
  
  let(:pdf) {PdfDocument::Base.new(valid_collection, valid_options)}
  
  it 's initialise avec une collection et des options' do
    PdfDocument::Base.new(valid_collection, {}) 
  end
  
  describe 'initialisation des variables d instance' do
    before(:each) do
      @pdfb = PdfDocument::Base.new(valid_collection, valid_options)
    end
    
    it 'affecte les variables d instance' do
      @pdfb.collection.should == valid_collection
     
      @pdfb.title.should == 'Ma spec'
    end
    
    describe 'orientation' do
      
      
      it 'par défaut landscape' do
        @pdfb.orientation.should == :landscape
      end
      
      it 'mais peut être surchargé' do
        pdf = PdfDocument::Base.new(valid_collection, valid_options.merge({:orientation=>:portrait}))
        pdf.orientation.should == :portrait
      end
    end
    
    
  end
  
  describe 'pour être valide' do
    
    it 'doit avoir les options obligatoire' do
      @pdfb = PdfDocument::Base.new(valid_collection, {}) 
      @pdfb.should_not be_valid
    end
    
    it 'est valide avec un titre et des columns' do
      @pdfb = PdfDocument::Base.new(valid_collection, valid_options )
      @pdfb.should be_valid
    end
    
    
  end
  
  describe 'les options par défaut' do
    before(:each) do
      @pdfb = PdfDocument::Base.new(valid_collection, valid_options)
    end
    
    it 'son nombre de ligne par défaut est NB_PER_PAGE_LANDSCAPE' do
      @pdfb.nb_lines_per_page.should == NB_PER_PAGE_LANDSCAPE
    end
    
    it 'mais on peut le changer' do
      pdfb = PdfDocument::Base.new(valid_collection, valid_options.merge(:nb_lines_per_page=>40))
      pdfb.nb_lines_per_page.should == 40
    end
    
    describe 'columns_widths' do
    
      it 'sait calculer les largeurs par défaut' do
        pdf.columns_widths.should == [50,50]
      end
    
      it 'mais on peut les changer' do
        pdf.columns_widths = [20,80]
        pdf.columns_widths.should == [20,80]
      end
    
      it 'et que le total fait 100' do
        expect {pdf.columns_widths= [20,70]}.to raise_error PdfDocument::PdfDocumentError
      end
    end
    
    describe 'columns_alignements' do
      it ':left par défaut' do
        pdf.columns_alignements.should == [:left, :left]
      end
      
      it 'mais on peut le changer' do
        @pdfb.columns_alignements = [:left, :right]
        @pdfb.columns_alignements.should == [:left, :right]
      end
      
      
    end
    
  end
  
  describe 'nb_pages' do
    
    it 'avec le modèle du spec de 100 lignes donne 5 pages' do
      pdf.nb_pages.should == 5
    end
    
    it 'mais 4 si on définit nb_lines_per_page à 25' do
      @pdfb = PdfDocument::Base.new(valid_collection, valid_options.merge({nb_lines_per_page:25}))
      @pdfb.nb_pages.should == 4
    end
    
    it 'il y a au moins une page, même si la collection est vide' do
      @pdfb = PdfDocument::Base.new([], valid_options)
      @pdfb.nb_pages.should == 1
    end
        
  end
  
  describe 'page' do
    
    it 'renvoie 22 lignes' do
      pdf.page(1).table_lines.should have(22).lines
    end
    
    it 'ne renvoie que 8 lignes pour la page 3' do
      pdf.page(5).table_lines.should have(12).lines
    end
    
    it 'et crée une erreur si la page n existe pas' do
      expect {pdf.page(6)}.to raise_error PdfDocument::PdfDocumentError, 'La page demandée est hors limite' 
    end
  end
  
  describe 'render' do
    it 'est capable de rendre son pdf' do
      pdf.organism_name = 'Organisme test'
      pdf.render
    end
  end
  
  
  
  
end
