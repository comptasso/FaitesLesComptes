# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'pdf_document/default'
require 'pdf_document/pdf_sheet'

describe PdfDocument::PdfSheet do

  let(:p) {stub_model(Period, start_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year)}
  let(:bal) {double(Compta::Sheet, :period=>p)}

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
        @pdfs.columns.should == ['title',  'net', 'previous_net']
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

    it 'fetch_lines'

    it 'render' do
      pending 'il faut d abord trouver comment mieux identifier les méthodes manquantes'
      bal.stub(:sens).and_return :actif
      @pdfs.render
    end

    it 'render pdf_text'


  end
  
end 