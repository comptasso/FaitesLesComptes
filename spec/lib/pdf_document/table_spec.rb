# coding: utf-8



require 'spec_helper'
require 'pdf_document/default'
require 'pdf_document/page'
require 'pdf_document/table'

RSpec.configure do |c|
  # c.filter = {wip:true}
end
 
describe PdfDocument::Table do

 

  let(:page) {mock(PdfDocument::Page, :number=>3, :document=>doc)}
  let(:doc) {stub(:columns_titles=>%w(Date Réf Débit Crédit),
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
    @table.stub(:lines).and_return([stub(:depth=>1),stub,  stub(:depth=>3)])
    @table.depths.should == [1,nil, 3]
  end

  it 'table sait faire son total' do
    @table.stub(:prepared_lines).and_return 1.upto(20).collect {|i| ['bonjour', i, -i, i/4.0]}
    @table.total_line.should == ['Totaux', 210, -210, 52.5]
  end

  
end

