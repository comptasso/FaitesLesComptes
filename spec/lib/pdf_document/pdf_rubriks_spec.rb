# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'pdf_document/pdf_rubriks'

describe 'PdfDocument::PdfRubriks' do

  let(:p) {mock_model(Period)}
  let(:cr) {stub(:class=>Compta::Rubrik, :title=>'Une rubrik',:net=>2, :previous_net=>1.2)}
  let(:crs) { stub(:class=>Compta::Rubriks, :title=>'Une rubriks',:net=>20, :previous_net=>12)}
  let(:source) {stub(:collection=>(1.upto(5).collect {crs} + [cr]),  :title=>'La source',:net=>200, :previous_net=>120)}

  it 'crée l instance' do
    pdfr = PdfDocument::PdfRubriks.new(p, source, {})
    pdfr.should be_an_instance_of PdfDocument::PdfRubriks
  end

  describe 'fonctionnalités' do
    before(:each) do
      @pdfr = PdfDocument::PdfRubriks.new(p, source, {})
      @pdfr.set_columns([:title, :net, :previous_net]) # pour que le render ait des colonnes
    end

    it 'nb_pages est toujours égal à un' do
      @pdfr.nb_pages.should == 1
    end

    it 'fetch_lines renvoie un tableau de toutes les rubrik' do
      crs.stub_chain(:to_pdf, :fetch_lines).and_return([cr,cr])
      @pdfr.fetch_lines.should have(12).elements # 5 crs avec chacun 2 plus le cr plus le total général
    end

   
  end


end
