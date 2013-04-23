# coding: utf-8

require 'spec_helper'

require 'pdf_document/default'
require 'editions/general_ledger_page' 
require 'pdf_document/page'

RSpec.configure do |config|
  # config.filter = {wip:true}
end

describe Editions::GeneralLedgerPage do

  let(:doc) {double(Compta::PdfGeneralLedger)}
  let(:monthly_ledgers) {double(Compta::MonthlyLedger, total_debit:1200.50, total_credit:10000.02)}

  before(:each) do
    monthly_ledgers.stub(:title_line).and_return({mois:"Mois de Fructose", title:'', description:'', debit:'', credit:''})
    monthly_ledgers.stub(:lines).and_return([{mois:'', title:'ES', description:'Essai', :debit=>1200.50, :credit=>10000.02},
     {mois:'', title:'VE', description:'Ventes', :debit=>0, :credit=>225000.25}])
    monthly_ledgers.stub(:total_line).and_return({mois:"Total Fructose", title:'', description:'', debit:1200.50, credit:10000.02})
  end

  describe 'french_format' do

    before(:each) do
      lsm = [monthly_ledgers]
      @glp = Editions::GeneralLedgerPage.new(doc,lsm ,1)
    end

    it 'répond à titre avec un array défini' do
      @glp.table_title.should ==  %w(Mois Journal Libellé Debit Credit)
    end

    describe 'table_lines' do
      it 'renvoie les lignes de la table' do
        @glp.table_lines.second.should == ['', 'ES', 'Essai', '1 200,50', '10 000,02']
      end
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
