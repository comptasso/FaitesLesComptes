require 'spec_helper'

describe Compta::GeneralBooksController do
  include SpecControllerHelper 

  before(:each) do  
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true 
  end
  
  describe 'Get new' do
    it 'crée une instance de GeneralBook' do
      get :new, {:period_id=>@p.to_param}, session_attributes
      assigns(:general_book).should be_an_instance_of(Compta::GeneralBook)
    end
    
    it 'intialisée avec des valeurs par défauts' do
      Compta::GeneralBook.should_receive(:new).with(period_id:@p.id).and_return(@gb = double(Compta::GeneralBook))
      @gb.should_receive(:with_default_values)
      get :new, {:period_id=>@p.to_param}, session_attributes
    end
  end
  
  describe 'production du pdf' do
    
    def pdf_attributes
      {period_id:@p.to_param,
        compta_general_book:{"from_date"=>@p.start_date, "to_date"=>@p.close_date, 
        "from_account_id"=>1, "to_account_id"=>88} } 
    end
    
    def merged_attributes
      {:period_id=>@p.id}.merge({"from_date"=>@p.start_date, "to_date"=>@p.close_date, 
        "from_account_id"=>1, "to_account_id"=>88})
    end
    
    describe 'produce_pdf' do
      it 'lance la production du pdf' do 
        @p.stub(:export_pdf).and_return(mock_model(ExportPdf, status:'mon statut'))
        @p.stub(:create_export_pdf).and_return(mock_model(ExportPdf, status:'mon statut'))
        Jobs::GeneralBookPdfFiller.stub(:new).and_return double(Object, perform:'delayed_job')
        xhr :get, :produce_pdf, pdf_attributes.merge({format:'js'}), session_attributes
      end
      
      it 'en le mettant dans la queue' do
        @p.stub(:export_pdf)
        @p.stub(:create_export_pdf).and_return(@expdf =  mock_model(ExportPdf, status:'new'))
        Compta::GeneralBook.any_instance.stub(:valid?).and_return true
        Jobs::GeneralBookPdfFiller.should_receive(:new).
          with(@o.database_name, @expdf.id, merged_attributes).and_return(@gb_filler = double(Jobs::GeneralBookPdfFiller))
        Delayed::Job.should_receive(:enqueue).with @gb_filler
        xhr :get, :produce_pdf, pdf_attributes.merge(format:'js'), session_attributes
      end
      
    end

    describe 'pdf_ready' do 
      it 'interroge si prêt' do
        @p.stub(:export_pdf).and_return(mock_model(ExportPdf, status:'mon statut'))
        xhr :get, :pdf_ready, {:period_id=>@p.to_param, format:'js'}, session_attributes
        response.body.should == 'mon statut' 
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

end
