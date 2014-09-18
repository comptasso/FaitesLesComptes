# coding: utf-8

require 'spec_helper'

require 'pdf_document/default'
require 'editions/general_ledger_page' 
require 'pdf_document/page'

RSpec.configure do |config| 
  # config.filter = {wip:true}
end

describe Editions::GeneralLedgerPage do  

  let(:doc) {double(Compta::PdfGeneralLedger, precision:2)}
  let(:monthly_ledgers) {double(Compta::MonthlyLedger, total_debit:1200.50, total_credit:10000.02)}

  before(:each) do
    monthly_ledgers.stub(:lines_with_total).and_return([
        {mois:"Mois de Fructose", abbreviation:'', title:'', debit:'', credit:''},
        {mois:'', abbreviation:'ES', title:'Essai', :debit=>1200.50, :credit=>10000.02},
        {mois:'', abbreviation:'VE', title:'Ventes', :debit=>0, :credit=>225000.25},
        {mois:"Total Fructose", abbreviation:'', title:'', debit:1200.50, credit:10000.02}
      ]
    )
  end

  describe 'french_format' do

    before(:each) do
      lsm = [monthly_ledgers]
      @glp = Editions::GeneralLedgerPage.new(doc,lsm ,1)
    end

    it 'répond à titre avec un array défini' do
      @glp.table_title.should ==  %w(Mois Jnl Libellé Debit Credit)
    end

    describe 'table_lines' do
      it 'renvoie les lignes de la table' do
        @glp.table_lines.first.should == ["Mois de Fructose", "", "", "", ""]
        @glp.table_lines.second.should == ['', 'ES', 'Essai', '1 200,50', '10 000,02']
        @glp.table_lines.last.should == ["Total Fructose", "", "", "1 200,50", "10 000,02"]
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

  it 'une page supérieure à 1 sait collecter des report values' do
      lsm = [monthly_ledgers]
      doc.should_receive(:page).with(1).and_return(double(:to_report_values=>['125,00', '56,00']))
      @glp = Editions::GeneralLedgerPage.new(doc,lsm ,2)
      @glp.table_report_line.should == ['Reports', '125,00', '56,00'] 

    end






end
