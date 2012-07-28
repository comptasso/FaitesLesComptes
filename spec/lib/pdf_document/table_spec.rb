# coding: utf-8



require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper') 
require 'pdf_document/base'
require 'pdf_document/page'
require 'pdf_document/table'

describe PdfDocument::Table do

  let(:arel) {double(Arel, count:100, 
      first:mock_model(Line))}
  let(:source) {mock_model(Account, title:'Achats', number:'60',
      lines:arel )}
  let(:o) {mock_model(Organism, title:'Organisme test')}
  let(:p) {mock_model(Period, organism:o,
      from_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year,
      exercice:'Exercice 2012')}


  let(:doc) {PdfDocument::Base.new(p, source, title:'Le document de base')}


  before(:each) do
    @l = mock_model(Line, line_date:Date.today, ref:nil, debit:10, credit:0)
    arel.stub_chain(:select, :offset, :limit).and_return 1.upto(22).collect {|i| @l}
    doc.set_columns_titles( %w(Date Réf Débit Crédit) )
    doc.set_columns(%w(line_date ref debit credit)) 
    @page = doc.page(2)
    
  end

  
  it 'table_title correspond aux noms de colonnes indiqué par le doc' do
    @page.table_title.should == %w(Date Réf Débit Crédit)
  end

  it 'table_lines doit avoir 22 lignes' do
    @page.table_lines.should have(22).lines # 22 est la valeur par défaut 
  end

  it 'la table ne doit reprendre que les colonnes demandées' do  
    @page.table_lines.first.should == [(Date.today -1),nil, 10.0, 0]
  end


  describe 'gestion des totaux' do
    it 'la table doit pouvoir écrire le total sur les lignes qui conviennent' do
      doc.set_columns_to_totalize([2,3])
      @page.table_total_line.should == ['Totaux', 22*10, 0]
    end
  
    it 'la table doit pouvoir écrire le total sur les lignes qui conviennent' do
      doc.set_columns_to_totalize([2])
      @page.table_total_line.should == ['Totaux', 22*10]
    end

    it 'la table doit avoir sa ligne de report' do
      doc.set_columns_to_totalize([2])
      @page.table_report_line.should == ['Reports', 220]
    end
  end


end

