# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'pdf_document/default.rb' 

describe Compta::PdfGeneralLedger do

  let(:p) {stub_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)}

  it 'can create a PdfGeneralLedger' do
    Compta::PdfGeneralLedger.new(p).should be_an_instance_of(Compta::PdfGeneralLedger)
  end

  it 'raise an error si le nombre de journaux dépasse les limites de la page' do
      Compta::MonthlyLedger.any_instance.stub(:size).and_return 200
      expect {Compta::PdfGeneralLedger.new(p)}.to raise_error('Trop grand nombre de journaux')
  end

  describe 'les méthodes de la classe' do

    before(:each) do
      Compta::MonthlyLedger.any_instance.stub(:size).and_return 4 # cas général
      # il y a 4 journaux à priori
      @pgl = Compta::PdfGeneralLedger.new(p)
    end

    it 'monthly_ledgers crée une collection de monthly_ledgers' do
      mls= @pgl.monthly_ledgers
      mls.should be_an_instance_of(Array)
      mls.should have(12).elements
      mls.first.should be_an_instance_of(Compta::MonthlyLedger)
    end

     it 'pages est un hash donnant les limites des mois' do
      @pgl.pages.should == {1=>0..4, 2=>5..10, 3=>11..11}
    end

    it 'nb pages renvoie le nombre de pages'do
      @pgl.nb_pages.should == 3 # cas général
      # si on a plus de journaux (6) le nb_de pages est plus élevé
      Compta::MonthlyLedger.any_instance.stub(:size).and_return 6 # cas général
      Compta::PdfGeneralLedger.new(p).nb_pages.should == 4
    end

   

    it 'page renvoie une instance de PdfDocument::GeneralLedgerPage' do
      @pgl.page(1).should be_an_instance_of(Editions::GeneralLedgerPage)
    end


  end


end
