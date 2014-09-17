# coding: utf-8



require 'spec_helper'
require 'pdf_document/default'
require 'pdf_document/page'
require 'pdf_document/table'

RSpec.configure do |c|
  # c.filter = {wip:true}
end 
 
describe PdfDocument::Table do

 

  let(:page) {double(PdfDocument::Page, :number=>3, :document=>doc)}
  let(:doc) {double(:columns_titles=>%w(Date Réf Débit Crédit),
      :prepare_line=>%w(un,deux),
      :columns_to_totalize=>[1,2,3]
    )}


  before(:each) do
    @table = PdfDocument::Table.new(page)
  end

  it 'a une instance de table' do
    
    @table.should be_an_instance_of(PdfDocument::Table)
  end

  it 'qui délègue ses titres à la méthode column_titles' do
    @table.title.should == doc.columns_titles
  end

  it 'appelle fetch_lines pour lire les lignes' do
    doc.should_receive(:fetch_lines).with(3).and_return 'bonjour'
    @table.lines.should == 'bonjour'
  end

  it 'prepared_lines renvoie des lignes préparées par la méthode de doc' do
    doc.stub(:fetch_lines).and_return(1.upto(10))
    doc.should_receive(:prepare_line).exactly(10).times.and_return 'OK'
    @table.prepared_lines.should == 1.upto(10).collect {'OK'}
  end

  it 'sait renvoyer un tableau des profondeurs de lignes' do
    @table.stub(:lines).and_return([double(:depth=>1),double,  double(:depth=>3)])
    @table.depths.should == [1,nil, 3]
  end

  it 'table sait faire son total' do
    @table.stub(:lines).and_return 1.upto(20).collect { |j| ['bonjou', j, -j, j/4.0]}
    @table.stub(:prepared_lines).and_return 1.upto(20).collect {|i| ['bonjour', i, -i, i/4.0]}
    @table.total_line.should == ['Totaux', 210, -210, 52.5]
  end
  
  it 'table sait aussi totaliser avec des TableLine' do
    @table.stub(:lines).and_return 1.upto(20).
      collect { |j| PdfDocument::TableLine.new(
        ['601', j, 50, 10.10],
        %w(String Numeric Numeric Numeric)) }
    @table.total_line.should == ['Totaux', 210, 1000, 10.10*20]
    
    
  end
  
  it 'ou mélanger' do
    @table.stub(:lines).and_return( 1.upto(5).
      collect { |j| PdfDocument::TableLine.new(
        ['601', 1, 12, 10.10],
        %w(String Numeric Numeric Numeric)) } + 
      1.upto(5).collect { |i| ['ici peu importe', i, -1, 2]}
    )
    doc.stub(:prepare_line).and_return ['bonjour', 2, -3, 2]
    @table.total_line.should == ['Totaux', 15, 45, 10.10*5+10]
  end
  
  it 'les table_lines de type subtotal ne sont pas additionnées' do
    @table.stub(:lines).and_return(tls =  1.upto(5).
      collect { |j| PdfDocument::TableLine.new(
        ['601', 1, 12, 10.10],
        %w(String Numeric Numeric Numeric), {subtotal:true}) } + 
      1.upto(5).collect { |i| ['ici peu importe', i, -1, 2]}
    )
    
    doc.stub(:prepare_line).and_return ['bonjour', 2, -3, 2]
    @table.total_line.should == ['Totaux', 10, -15, 10]
  end

  
end

