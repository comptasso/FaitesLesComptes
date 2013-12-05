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
  end
  
  subject {Jobs::SheetsPdfFiller.new('assotest1', expdf.id, period_id:p.id, collection:['actif', 'passif'])}
  
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
      ExportPdf.stub(:find).and_return(expdf)
      Period.stub(:find).and_return p
      nomen.stub_chain(:folios, :find_by_name).and_return(folio)
      subject.before(double Object)
      subject.instance_variable_get('@docs').should be_an_instance_of(Array)
    end
    
    it 'même si le document n existe pas' do
      ExportPdf.stub(:find).and_return(expdf)
      nomen.stub_chain(:folios, :find_by_name).and_return(nil)
      
      subject.before(double Object)
      subject.instance_variable_get('@docs').should == []
    end
  
  end
   
end