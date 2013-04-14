# coding: utf-8

require 'spec_helper'

require 'pdf_document/default'
require 'pdf_document/general_ledger_page'
require 'pdf_document/page'

RSpec.configure do |config|
 # config.filter = {wip:true}
end

describe PdfDocument::GeneralLedgerPage do 

  let(:doc) {double(Compta::PdfGeneralLedger)}
  let(:monthly_ledgers) {double(Compta::MonthlyLedger, total_debit:1200.50, total_credit:10000.02)}

  describe 'french_format' do




  before(:each) do
    lsm = [monthly_ledgers]

    @glp = PdfDocument::GeneralLedgerPage.new(doc,lsm ,1)
    @glp.stub(:fetch_lines).and_return([{mois:'Janvier', title:'ES', description:'Essai', debit:1200.50, credit:10000.02}])

  end

  it 'affiche les valeurs en format francais' do 
    
    @glp.table_lines.should == [['Janvier', 'ES', 'Essai', '1 200,50', '10 000,02']]
  end

    it 'le total line' do
      @glp.table_total_line.should == ['Totaux', '1 200,50', '10 000,02'] 
    end

    it 'table_to_report_line' do
      
      doc.stub(:nb_pages).and_return 1
      
      @glp.table_to_report_line.should == ['Totaux généraux', '1 200,50', '10 000,02']
    end


  end






end
