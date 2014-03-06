# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |config| 
  #  config.filter =  {wip:true}
end



describe Jobs::SheetsPdfFiller do  
  
  let(:p) {mock_model(Period, :organism=>mock_model(Organism, :nomenclature=>nomen))}
  let(:expdf) {ExportPdf.new}
  let(:nomen) {Nomenclature.new}
  let(:folio) {Folio.new(:name=>'resultat')}
  
  before(:each) do
    Period.stub(:find).and_return p
    ExportPdf.stub(:find).and_return(expdf)
  end
  
  subject {Jobs::SheetsPdfFiller.new(SCHEMA_TEST, expdf.id, period_id:p.id, collection:['actif', 'passif'])}
  
  it 'crée une instance' do
    subject.should be_an_instance_of(Jobs::SheetsPdfFiller)
  end
  
  describe(:before) do
  
    it 'trouve l export_pdf' do
      ExportPdf.should_receive(:find).with(expdf.id).and_return(expdf)
      subject.stub(:set_document)
      subject.before(double Object)
    end
    
    it 'et assigne la variable docs' do
      
      nomen.stub_chain(:folios, :find_by_name).and_return(folio)
      subject.before(double Object)
      subject.instance_variable_get('@docs').should be_an_instance_of(Array)
    end
    
    it 'même si le document n existe pas' do
      nomen.stub_chain(:folios, :find_by_name).and_return(nil)
      subject.before(double Object)
      subject.instance_variable_get('@docs').should == []
    end
  
  end
  
  describe 'perform' do
    
    let(:resultat) {Editions::Sheet.new(p, double(Compta::Sheet, sens: :passif), {title:'Compte de Résultats'})}
    
    before(:each) do
      Folio.any_instance.stub(:sens).and_return 'passif'
      subject.instance_variable_set('@docs', [resultat])
      subject.instance_variable_set('@export_pdf', expdf)
    end
            
    it 'appelle produce_pdf avec les documents' do
      subject.should_receive(:produce_pdf).with([resultat]).and_return(double(Editions::PrawnSheet, render:'bonjour'))
      subject.perform
    end
    
    it 'puis render' do
      subject.stub(:produce_pdf).with([resultat]).and_return(@aps = double(Editions::PrawnSheet))
      @aps.should_receive(:render).and_return('bonjour')
      subject.perform
    end
    
    it 'et met à jour PdfExport puis le sauve' do
      subject.stub_chain(:produce_pdf, :render).and_return('bonjour')
      expdf.should_receive('content=').with('bonjour')
      expdf.should_receive(:save)
      subject.perform
    end
  end
   
end