# coding: utf-8 

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::BalancesController do 
  include SpecControllerHelper
 
  def valid_attributes
      {from_date:Date.today.beginning_of_year, to_date:Date.today.end_of_month, 
        period_id:@p.id, 
        from_account_id:1,
        to_account_id:99
      }
  end

  before(:each) do 
    minimal_instances
    @p.stub(:all_natures_linked_to_account?).and_return true  
  end
  
  describe "GET new" do
    it "assigns a new balance" do 
      get :new, {:period_id=>@p.id.to_s}, valid_session
      assigns(:balance).should be_a_new(Compta::Balance)
    end

    
  end

  describe "POST create" do
    

    describe "with valid params" do
      it "assigns a newly Balance as @balance" do
        post :create, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes}, valid_session
        assigns(:balance).should be_a(Compta::Balance)
      end

      it "render show when balance is valid" do
        Compta::Balance.any_instance.stub(:valid?).and_return(true)
        post :create, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes}, valid_session
        response.should render_template("show")
      end

#      it 'rend le pdf' do
#        Compta::Balance.any_instance.stub(:valid?).and_return(true)
#        post :create, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes, :format=>'pdf'}, valid_session
#        response.status.should == 200
#      end

      

      it "render new when invalid" do
        Compta::Balance.any_instance.stub(:valid?).and_return(false)
        post :create, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes}, valid_session
        response.should render_template("new")
      end
    end

    describe 'GET show' do

      it 'assigne @balance' do
        get :show, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes}, valid_session
        assigns(:balance).should be_a(Compta::Balance)
      end

      it 'sans params[:compta_balance] redirige vers new' do
        get :show, {:period_id=>@p.id.to_s}, valid_session
        response.should redirect_to new_compta_period_balance_url(@p) 
      end

      it 'rend le csv' do
        Compta::Balance.any_instance.stub(:valid?).and_return(true)
        Compta::Balance.any_instance.stub(:to_csv).and_return('Bonsoir')
        @controller.should_receive(:send_data).with('Bonsoir', filename:"Balance #{@o.title} #{@controller.dashed_date(Date.today)}.csv").and_return { @controller.render nothing: true }
        get :show, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes, :format=>'csv'}, valid_session
      end

       it 'rend le xls' do 
        Compta::Balance.any_instance.stub(:valid?).and_return true
        Compta::Balance.any_instance.stub(:to_xls).and_return 'Bonjour'
        @controller.should_receive(:send_data).with('Bonjour', filename:"Balance #{@o.title} #{@controller.dashed_date(Date.today)}.csv").and_return { @controller.render nothing: true }
        get :show, {:period_id=>@p.id.to_s, :compta_balance=>valid_attributes, :format=>'xls'}, valid_session
      end


    end
    
    describe 'GET deliver_pdf' do 
      it 'construit le fichier et le rend' do
        @p.should_receive(:export_pdf).and_return(mock_model(ExportPdf, status:'ready'))
        get :deliver_pdf,{ :period_id=>@p.to_param, :compta_balance=>valid_attributes, format:'js'}, session_attributes
        response.content_type.should == "application/pdf" 
      end
    end

    
  end

end

