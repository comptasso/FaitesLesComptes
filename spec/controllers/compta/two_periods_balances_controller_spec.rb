  # coding: utf-8 

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::TwoPeriodsBalancesController do 
  include SpecControllerHelper 
  
    before(:each) do
      minimal_instances 
      controller.stub(:check_natures).and_return true  
    end
  
    describe 'GET show' do
      it 'crée une instance de Compta::TwoPeriodsBalance' do
        Compta::TwoPeriodsBalance.should_receive(:new).with(@p).and_return(@ctpb = double(Compta::TwoPeriodsBalance))
        @ctpb.should_receive(:lines).and_return
        get :show, {period_id:@p.id}, valid_session
      end
      
      it 'et assigne les lignes' do
        Compta::TwoPeriodsBalance.stub_chain(:new, :lines).and_return(@arr = double(Array))
        get :show, {period_id:@p.id}, valid_session
        assigns(:detail_lines).should == @arr
      end 
      
      it 'rend le template show' do
        Compta::TwoPeriodsBalance.stub_chain(:new, :lines).and_return(@arr = double(Array))
        get :show, {period_id:@p.id}, valid_session
        response.should render_template 'show'
      end
    end
    
    describe 'produce_pdf' do 
      before(:each) do
        @p.stub(:export_pdf)
        @p.stub(:create_export_pdf).and_return(@expdf =  mock_model(ExportPdf, status:'new'))
        # on surcharge BasePdfFiller car on veut tester le controller pas le Filler
        Jobs::BasePdfFiller.any_instance.stub(:before).and_return nil
       end
      
      it 'en le mettant dans la queue' do
        Jobs::TwoPeriodsBalancePdfFiller.should_receive(:new).
          with(@o.database_name, @expdf.id, {period_id:@p.id} ).and_return(@ctpb = double(Jobs::TwoPeriodsBalancePdfFiller))
        Delayed::Job.should_receive(:enqueue).with @ctpb
        xhr :get, :produce_pdf, {format:'js'}, session_attributes
      end
      
    end
    
    describe 'GET deliver_pdf' do 
      it 'construit le fichier et le rend' do
        @p.should_receive(:export_pdf).and_return(mock_model(ExportPdf, status:'ready'))
        get :deliver_pdf,{format:'js'}, session_attributes
        response.content_type.should == "application/pdf" 
      end
    end
end