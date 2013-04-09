# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'pdf_document/simple'
load 'pdf_document/totalized.rb'
require 'pdf_document/page'

describe 'PdfDocument::Totalized' do

  let(:o) {mock_model(Organism, title:'Organisme test')}
  let(:p) {mock_model(Period, organism:o,
      start_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year,
      exercice:'Exercice 2012',
      accounts: [1,2])}

  def valid_options
    {
      title:'PDF Document' ,
      subtitle:'Le sous titre',
      :select_method=>'accounts'
     }
  end


  it 'peut être instancié' do
    PdfDocument::Totalized.new(p, p, valid_options).should be_an_instance_of(PdfDocument::Totalized) 
  end

  context 'avec une instance' do

    before(:each) do
     @pdf =  PdfDocument::Totalized.new(p, p, valid_options)
     p.stub_chain(:accounts, :first, :class, :column_names).and_return %w(un deux trois quatre cinq six sept)
    end

    it 'calcule correctement les largeurs de la ligne des totaux' do
      @pdf.set_columns_widths [10, 40, 10, 10, 10, 10, 10]
      @pdf.set_columns_to_totalize [2,3,4,5,6]
      @pdf.set_total_columns_widths
      @pdf.total_columns_widths.should == [50,10,10,10,10,10]
    end

    it 'sait préparer une ligne' do
      p.stub_chain(:accounts, :first, :class, :column_names).and_return %w(un deux)
      @cl = mock_model(ComptaLine, :un=>'bonjour', :deux=>'Au revoir')
      @pdf.prepare_line(@cl).should == ['bonjour', 'Au revoir']

    end


  end




end