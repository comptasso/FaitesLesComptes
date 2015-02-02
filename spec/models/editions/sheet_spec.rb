# coding: utf-8

require 'spec_helper'
require 'pdf_document/default'
require 'editions/sheet'

describe Editions::Sheet do
  let(:o) {stub_model(Organism, :name=>'Ma petite Affaire')}
  let(:p) {stub_model(Period, organism:o, start_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year)}
  let(:bal) {double(Compta::Sheet, :period=>p, :sens=>:actif, :name=>:actif)} # pour un actif de bilan 

  it 'création du PdfSheet' do
    pdfs = Editions::Sheet.new(p, bal, {title:'Balance test'} )
    pdfs.should be_an_instance_of(Editions::Sheet)
  end
  
  describe 'les méthodes de pdf sheet' do
    
    subject {Editions::Sheet.new(p, bal, {title:'Balance test'} )}

    
    it 'page renvoie 1' do
      subject.nb_pages.should == 1
    end


      it 'les colonnes dépendent du sens de la source' do
        bal.stub(:sens).and_return(:actif)
        subject.columns_methods.should == ['title', 'brut', 'amortissement', 'net', 'previous_net']
      end

     it 'les colonnes dépendent du sens de la source' do
        bal.stub(:sens).and_return(:passif)
        subject.columns_methods.should == ['title',  'net', 'previous_net']
      end


      describe 'les titres des colonnes dépendent du type de document' do

      it 'si le document a pour name actif' do 
        bal.stub(:name).and_return('actif')
        bal.stub(:sens).and_return(:actif) 
        subject.columns_titles.should == ["", "Brut", "Amortisst\nDépréciat°", "Net au \n#{I18n.l p.close_date}", "Net au \n#{I18n.l(p.start_date - 1)}"]
      end

      it 'si le document a pour name passif' do
        bal.stub(:name).and_return('passif')
        bal.stub(:sens).and_return(:passif) 
        subject.columns_titles.should == ['',  I18n.l(p.close_date), I18n.l((p.start_date) -1)]
      end
      
      it 'pour les autres' do
        bal.stub(:name).and_return(:peu_importe)
        subject.columns_titles.should == ['', p.short_exercice, p.previous_exercice]
      end

      end

    it 'stamp' do
      p.stub_chain(:compta_lines, :unlocked, :any?).and_return false
      subject.stamp.should == ''
      p.stub_chain(:compta_lines, :unlocked, :any?).and_return true
      subject.stamp.should == 'Provisoire'
    end

      

    it 'fetch_lines' do
      bal.should_receive(:folio).and_return(@fol = double(Folio))
      @fol.stub_chain(:root, :fetch_compta_rubriks).and_return('une liste de rubriques')
      subject.fetch_lines.should == 'une liste de rubriques' 
    end

    it 'render' do
      ligne = double(:title=>'Libelle', :brut=>'200,00', :amortissement=>'10,00', :net=>'190,00', :previous_net=>'180,25', :depth=>0)
      subject.stub(:fetch_lines).and_return(10.times.map {|i| ligne })
      subject.render
    end

    it 'render pdf_text' do
      ligne = double(:title=>'Libelle', :brut=>'200,00', :amortissement=>'10,00', :net=>'190,00', :previous_net=>'180,25', :depth=>0)
      subject.stub(:fetch_lines).and_return(10.times.map {|i| ligne })
      pdf = Editions::PrawnSheet.new
      subject.render_pdf_text(pdf)
    end


  end
  
end 