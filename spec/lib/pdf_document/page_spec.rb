# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'pdf_document/page'
require 'pdf_document/base'

describe PdfDocument::Page do
  let(:o) {mock_model(Organism, title:'Organisme test')}
  let(:p) {mock_model(Period, organism:o,
      from_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year,
      exercice:'Exercice 2012')}
  let(:arel) {double(Arel, count:100, first:mock_model(Line, line_date:Date.today, debit:12, credit:0))}
  let(:source) {mock_model(Account, title:'Achats', number:'60',
      lines:arel )}


  let(:doc) {PdfDocument::Base.new(p, source, {title:'Le titre de la page'}) }



  before(:each) do
    doc.set_columns_titles  %w(Date Débit Crédit)
    @page = PdfDocument::Page.new(2, doc)
  end

  it "should desc" do
    @page.should be_an_instance_of(PdfDocument::Page)
  end

  it 'should know his page number' do
    @page.number.should == 2
  end

  describe 'doit être capable de fournir toutes les informations au template' do
    it 'répond à left_top' do
      @page.top_left.should ==  "Organisme test\nExercice 2012"
    end

    it 'répond à top middle' do
      @page.title.should == 'Le titre de la page'
    end

    it 'avec un sous titre s il existe' do
      doc.stub(:subtitle).and_return'Le sous titre'
      @page.subtitle.should == "Le sous titre"
    end

    it "répond à top_right" do
      @page.top_right.should == "#{I18n::l Time.now}\nPage 2/#{doc.nb_pages}"
    end

    it "repond à table_title" do
       @page.table_title.should == %w(Date Débit Crédit)
    end

  describe 'lines total et reports'  do

    before(:each) do
      @l = mock_model(Line, line_date:Date.today, debit:10, credit:0)
      arel.stub_chain(:select, :offset, :limit).and_return 1.upto(22).collect {|i| @l}
      doc.set_columns %w(line_date debit credit)
      doc.set_columns_to_totalize [1,2]
      @page = doc.page 3
    end
    it 'faut pouvoir indiquer les colonnes à totaliser' do
      @page.table_total_line.should == ['Totaux', 220,0]
    end

      it 'la page 1 n a pas de ligne report' do
        doc.page(1).table_report_line.should be_nil
      end
      
      it 'la page 3 doit avoir un report de 440' do
        @page.table_report_line.should == ['Reports', 440, 0]
      end

      it 'la page a une ligne à reporter' do
        @page.table_to_report_line.should == ['A reporter', 660,0]
      end

      it 'la ligne à reporter est intitulée total general pour la dernière page' do
        doc.page(5).table_to_report_line.should == ['Total général', 1100, 0]
      end
  end


  end
end

