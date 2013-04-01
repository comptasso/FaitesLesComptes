# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'pdf_document/default'
require 'pdf_document/pdf_sheet'

describe PdfDocument::PdfSheet do
  let(:o) {stub_model(Organism, :name=>'Ma petite Affaire')}
  let(:p) {stub_model(Period, organism:o, start_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year)}
  let(:bal) {double(Compta::Sheet, :period=>p, :sens=>:actif, :name=>:actif)} # pour un actif de bilan

  it 'création du PdfSheet' do
    pdfs = PdfDocument::PdfSheet.new(p, bal, {title:'Balance test', select_method:'accounts'} )
    pdfs.should be_an_instance_of(PdfDocument::PdfSheet)
  end
  
  describe 'les méthodes de pdf sheet' do

    before(:each) do
      @pdfs = PdfDocument::PdfSheet.new(p, bal, {title:'Balance test', select_method:'accounts'} )
    end
    it 'page renvoie 1' do
      @pdfs.nb_pages.should == 1
    end


      it 'les colonnes dépendent du sens de la source' do
        bal.stub(:sens).and_return(:actif)
        @pdfs.columns.should == ['title', 'brut', 'amortissement', 'net', 'previous_net']
      end

     it 'les colonnes dépendent du sens de la source' do
        bal.stub(:sens).and_return(:passif)
        pdfs = PdfDocument::PdfSheet.new(p, bal, {title:'Balance test', select_method:'accounts'} )
        pdfs.columns.should == ['title',  'net', 'previous_net']
      end


      describe 'les titres des colonnes dépendent du type de document' do

      it 'si le document a pour name actif' do
        bal.stub(:name).and_return(:actif)
        @pdfs.columns_titles.should == ['',  I18n.l(p.close_date), I18n.l((p.start_date) -1)]
      end

      it 'si le document a pour name passif' do
        bal.stub(:name).and_return(:actif)
        @pdfs.columns_titles.should == ['',  I18n.l(p.close_date), I18n.l((p.start_date) -1)]
      end

      it 'pour les autres' do
        bal.stub(:name).and_return(:peu_importe)
        @pdfs.columns_titles.should == ['', p.exercice, p.previous_exercice]
      end

      end

    it 'stamp' do
      p.stub(:closed?).and_return true
      @pdfs.stamp.should == ''
      p.stub(:closed?).and_return false
      @pdfs.stamp.should == 'Provisoire'
    end

    it 'lit le template' do
      @pdfs.send(:template).should == "lib/pdf_document/prawn_files/actif.pdf.prawn"
    end

    it 'fetch_lines' do
      @cr = double(Compta::Rubriks, :class=>Compta::Rubriks)
      @cr.stub_chain(:to_pdf, :fetch_lines).and_return([['Libellé', 200, 10, 190, 180,25]])
      bal.stub_chain(:total_general, :collection).and_return(10.times.map {|i| @cr })
      @pdfs.fetch_lines.size.should == 10
    end

    it 'render' do
      ligne = stub(:title=>'Libelle', :brut=>'200,00', :amortissement=>'10,00', :net=>'190,00', :previous_net=>'180,25', :depth=>0)
      @pdfs.stub(:fetch_lines).and_return(10.times.map {|i| ligne })
      @pdfs.render
    end

    it 'render pdf_text' do
      ligne = stub(:title=>'Libelle', :brut=>'200,00', :amortissement=>'10,00', :net=>'190,00', :previous_net=>'180,25', :depth=>0)
      @pdfs.stub(:fetch_lines).and_return(10.times.map {|i| ligne })
      pdf = Prawn::Document.new
      @pdfs.render_pdf_text(pdf)
    end


  end
  
end 