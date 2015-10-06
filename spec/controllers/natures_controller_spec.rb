require 'spec_helper'
require 'support/spec_controller_helper'
# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe NaturesController do
  include SpecControllerHelper

  describe "GET index" do


    let(:nr1) {mock_model(Nature, period_id:@p.id, income_outcome:true)}
    let(:nr2) {mock_model(Nature, period_id:@p.id, income_outcome:true)}
    let(:nd1) {mock_model(Nature, period_id:@p.id, income_outcome:false)}
    let(:nd2) {mock_model(Nature, period_id:@p.id, income_outcome:false)}
    let(:nd3) {mock_model(Nature, period_id:@p.id, income_outcome:false)}




    before(:each) do
      minimal_instances
      @p.stub_chain(:natures, :recettes).and_return [nr1, nr2]
      @p.stub_chain(:natures, :depenses).and_return [nd1, nd2, nd3]

    end


    it 'assigns @organism and @period' do
      get :index , {:organism_id=>@o.to_param, :period_id=>@p.to_param}, session_attributes
      assigns(:organism).should == @o
      assigns(:period).should == @p
      response.should be_success


    end

    it 'raise error without @organism or period' do
      expect { get :index}.to raise_error ActionController::RoutingError
    end

    it 'assigns @filter with 0 if no params[:filter]' do
      get :index, {:organism_id=>@o.id.to_s, :period_id=>@p.id.to_s}, session_attributes
      assigns(:filter).should == 0
    end

    it 'assigns sn (Natures)' do
      Stats::Natures.should_receive(:new).with(@p, [0]).and_return('sn')
      get :index,{ :organism_id=>@o.id.to_s, :period_id=>@p.id.to_s}, session_attributes
      assigns(:sn).should == 'sn'
    end

    it 'with filter' do
      filt = 1
      @o.should_receive(:destinations).and_return(@ar = double(Arel))
      @ar.should_receive(:find).with(filt).and_return(double(Object, name:'mock'))
      Stats::Natures.should_receive(:new).with(@p, [1]).and_return('sn')
      get :index, {:organism_id=>@o.id.to_s, :period_id=>@p.id.to_s, :destination=>filt.to_s},  session_attributes
      assigns(:filter).should == filt
    end

    describe 'production du pdf' do
      before(:each) do
        Jobs::BasePdfFiller.any_instance.stub(:before).and_return nil
      end

      it 'cherche l export pdf de period' do
        @p.should_receive(:export_pdf).and_return
        @p.stub(:create_export_pdf).and_return(mock_model(ExportPdf))
        Jobs::StatsPdfFiller.stub(:new).and_return(double(Object, perform:'test'))
        xhr :get, :produce_pdf,{ :organism_id=>@o.id.to_s, :period_id=>@p.to_param, format:'js'}, session_attributes
      end

      it 'le détruit s il existe' do
        @p.stub(:export_pdf).and_return(@obj = double(ExportPdf))
        @obj.should_receive(:destroy)
        @p.stub(:create_export_pdf).and_return(mock_model(ExportPdf))
        Jobs::StatsPdfFiller.stub(:new).and_return(double(Object, perform:'test'))
        xhr :get, :produce_pdf,{ :organism_id=>@o.id.to_s, :period_id=>@p.to_param, format:'js'}, session_attributes
      end

      it 'crée un export_pdf avec un status new' do
        @p.stub(:export_pdf).and_return nil
        @p.should_receive(:create_export_pdf).with(:status=>'new').and_return(mock_model(ExportPdf))
        Jobs::StatsPdfFiller.stub(:new).and_return(double(Object, perform:'test'))
        xhr :get, :produce_pdf,{ :organism_id=>@o.id.to_s, :period_id=>@p.to_param, format:'js'}, session_attributes

      end

      it 'crée la tâche' do
         @p.stub(:export_pdf).and_return nil
         @p.stub(:create_export_pdf).and_return(@exp = mock_model(ExportPdf))
         Jobs::StatsPdfFiller.should_receive(:new).with(@t.id, @exp.id, {period_id:@p.id, destination:[0]})
         Delayed::Job.stub(:enqueue)
         xhr :get, :produce_pdf,{ :organism_id=>@o.id.to_s, :period_id=>@p.to_param, format:'js'}, session_attributes
      end

      it 'le met en queue de delayed_job' do
        @p.stub(:export_pdf).and_return nil
        @p.stub(:create_export_pdf).and_return(@exp = mock_model(ExportPdf))
        Jobs::StatsPdfFiller.stub(:new).and_return(@obj = double(Object, :perform=>true))
        Delayed::Job.should_receive(:enqueue).with(@obj)
        xhr :get, :produce_pdf,{ :organism_id=>@o.id.to_s, :period_id=>@p.to_param, format:'js'}, session_attributes
      end

      it 'puis interroge ready qui renvoie le status' do
        @p.should_receive(:export_pdf).and_return(mock_model(ExportPdf, status:'pret'))
        xhr :get, :pdf_ready,{ :organism_id=>@o.id.to_s, :period_id=>@p.to_param, format:'js'}, session_attributes
        response.should be_success
        response.body.should == 'pret'
      end

      it 'et peut livrer le fichier' do
        @p.should_receive(:export_pdf).and_return(mock_model(ExportPdf, status:'ready'))
        get :deliver_pdf,{ :organism_id=>@o.id.to_s, :period_id=>@p.to_param, format:'js'}, session_attributes
        response.content_type.should == "application/pdf"
      end

      it 'deliver_pdf ne renvoie rien si le fichier n est pas prêt' do
        @p.should_receive(:export_pdf).and_return(mock_model(ExportPdf, status:'not_ready'))
        get :deliver_pdf,{ :organism_id=>@o.id.to_s, :period_id=>@p.to_param, format:'js'}, session_attributes
        response.body.should == ' '
      end

    end





  end

end
