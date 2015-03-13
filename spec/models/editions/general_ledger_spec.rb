# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'pdf_document/default.rb' 

describe Editions::GeneralLedger do 
  include OrganismFixtureBis

  let(:p) {stub_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)}

  it 'can create a Editions::GeneralLedger' do
    Editions::GeneralLedger.new(p).should be_an_instance_of(Editions::GeneralLedger)
  end
  
  context 'avec un organisme réel' do
    
    before(:each) {use_test_organism}
    subject { Editions::GeneralLedger.new(Period.first)}
    
    it 'nb pages renvoie le nombre de pages'do
      subject.nb_pages.should == 2 # cas général
    end
    
    it 'page renvoie une instance de PdfDocument::GeneralLedgerPage' do
      subject.page(1).should be_an_instance_of(PdfDocument::Page) 
    end
    
    it 'peut rendre un pdf' do
      expect {subject.render}.not_to raise_error
    end
    
  end
  
  describe 'tampon sur le document' do
    before(:each) {use_test_organism}
    
    after(:each) do
      erase_writings
    end
    
    it 'affiche le tampon provisoire si des lignes ne sont pas verrouillées' do
      create_outcome_writing
      ep = Editions::GeneralLedger.new(Period.first)
      expect(ep.stamp).to eql 'Provisoire'
    end
    
    it 'affiche un tampon vide sans ligne' do
      ep = Editions::GeneralLedger.new(Period.first)
      expect(ep.stamp).to eql ''
    end
    
    it 'affiche un tampon vide si toutes les lignes sont verrouillées' do
      w = create_outcome_writing
      w.compta_lines.each {|l| l.update_attribute(:locked, true)}
      ep = Editions::GeneralLedger.new(Period.first)
      expect(ep.stamp).to eql ''
    end
  end


end
