require 'spec_helper'

describe Compta::GeneralLedgersController do
  include SpecControllerHelper 
  

  before(:each) do
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true
    @p.stub(:export_pdf).and_return nil
  end

  describe 'pdf_ready' do 
    it 'interroge si prêt' do
      @p.stub(:export_pdf).and_return(mock_model(ExportPdf, status:'mon statut'))
      get :pdf_ready, {:period_id=>@p.to_param, format:'js'}, session_attributes
      response.body.should == 'mon statut' 
    end
  end
  
  describe 'produce_pdf' do
    it 'lance la production du pdf' do 
      @p.stub(:create_export_pdf).and_return(@expdf = mock_model(ExportPdf, status:'mon statut'))
      Jobs::GeneralLedgerPdfFiller.stub(:new).and_return double(Object, perform:'delayed_job')
      get :produce_pdf, {:period_id=>@p.to_param, format:'js'}, session_attributes
    end
    
    
  end
  
  describe 'GET deliver_pdf' do 
      it 'rend le fichier' do
        @p.should_receive(:export_pdf).and_return(mock_model(ExportPdf, status:'ready'))
        get :deliver_pdf, {:period_id=>@p.to_param, format:'js'}, session_attributes
        response.content_type.should == "application/pdf" 
      end
      
      
    end
  
  

end
