# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BankExtractsController do
  include SpecControllerHelper 


  let(:ba) {mock_model(BankAccount, name: 'IBAN', number: '124578A', organism_id: @o.id)}
  let(:be) {mock_model(BankExtract, bank_account_id: ba.id, begin_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month,
      begin_sold: 120, debit: 450, credit: 1000, end_sold: 120+1000-450)}
 
  
   def valid_params
      {"bank_account_id"=>ba.id.to_s,  "begin_sold"=>be.end_sold.to_s,
        "total_debit"=> 11.to_s, "total_credit"=> 37.to_s , "begin_date_picker"=> '01/05/2012',
      "end_date_picker"=> '31/05/2012' }
    end


  before(:each) do
   minimal_instances
    BankAccount.stub!(:find).and_return(ba)
   
  end

  describe "GET index" do
    it "sélectionne les extraits correspondant à l'exercice et les assigns à @bank_extracts" do
      ba.stub_chain(:bank_extracts, :period, :all).and_return([be])
      get :index,{:organism_id=>@o.id.to_s, bank_account_id: ba.id.to_s}, valid_session
      assigns[:period].should == @p
      assigns[:bank_extracts].should == [be]
    end
  end


  describe "GET new" do
    before(:each) do
      @new_bank_extract = BankExtract.new(bank_account_id: ba.id)
      ba.stub(:new_bank_extract).and_return(@new_bank_extract)
    end


    it "assigns bank_extract" do
      get :new, {:organism_id=>@o.id.to_s, bank_account_id: ba.id.to_s}, valid_session
      assigns(:bank_extract).should == @new_bank_extract
    end

    it "renders new template" do
      get :new,{ :organism_id=>@o.id.to_s, bank_account_id: ba.id.to_s}, valid_session
      response.should render_template 'new'
    end
  end

  describe "GET edit" do
   
    it "assigns the requested bank_extract as @bank_extract" do
      BankExtract.should_receive(:find).with(be.id.to_s).and_return be
      get :edit, {:organism_id=>@o.id.to_s, bank_account_id: ba.id.to_s, :id=>be.id}, valid_session
      assigns(:bank_extract).should == be
    end
  end

  describe "POST create" do
   
    before(:each) do
      ba.stub(:bank_extracts).and_return(BankExtract) # ce qui permet à new de fonctionner
      BankExtract.any_instance.stub(:fill_bank_extract_lines).and_return(nil)
      BankExtract.should_receive(:new).with(valid_params).and_return(@be = mock_model(BankExtract).as_new_record)
    end

    it "creates a new BankExtract" do
        @be.should_receive(:save).and_return true
        post :create, {:organism_id=>@o.id, :bank_account_id=> ba.id,
          :bank_extract => valid_params}, valid_session
        assigns(:bank_extract).should == @be
    end


    it "redirects to pointage when valid" do
        @be.stub(:save).and_return true
        post :create,{ :organism_id=>@o.id, :bank_account_id=> ba.id,
          :bank_extract => valid_params}, valid_session
        response.should redirect_to bank_account_bank_extracts_url(ba)
      end
    

     it "re-renders the 'new' template" do
        @be.stub(:save).and_return false
        post :create,{ :organism_id=>@o.id, :bank_account_id=> ba.id,
          :bank_extract => valid_params}, valid_session
        response.should render_template("new")
      end
   
  end
  #
  describe "PUT update" do

   
    before(:each) do
      BankExtract.any_instance.stub(:fill_bank_extract_lines).and_return(nil)
    end
    
    it "should look for bank_extract and assigns it" do
      BankExtract.should_receive(:find).with(be.id.to_s).and_return be
      be.stub(:update_attributes).and_return(true)
      put :update, {organism_id: @o.id, bank_account_id: ba.id, :id => be.id,
          :bank_extract => valid_params}, valid_session
      assigns(:bank_extract).should == be
    end

     it "updates the requested bank_extract" do
       BankExtract.stub(:find).and_return be
       be.should_receive(:update_attributes).with(valid_params)
       put :update, {organism_id: @o.id, bank_account_id: ba.id, :id => be.id,
          :bank_extract => valid_params}, valid_session
      end

      it "with valid attributes, redirects to index" do
        BankExtract.stub(:find).and_return be
        be.stub(:update_attributes).and_return true
        put :update, {organism_id: @o.id, bank_account_id: ba.id, :id => be.id, :bank_extract => valid_params}, valid_session
        response.should redirect_to bank_account_bank_extracts_url(ba)
      end
    
     

      it "re-renders the 'edit' template when invalid attributes" do
        BankExtract.stub(:find).and_return be
        be.stub(:update_attributes).and_return false
        put :update, {bank_account_id: ba.id, :id => be.id, :bank_extract => valid_params}, valid_session
        response.should render_template("edit")
      end
    
  end

  describe "DELETE destroy" do

   
    before(:each) do
      BankExtract.any_instance.stub(:fill_bank_extract_lines).and_return(nil)
    end
    
     
     it "should look_for the bank_extract" do
      BankExtract.should_receive(:find).with(be.id.to_s).and_return(be)
      delete :destroy, { bank_account_id: ba.id, :id => be.id}, valid_session
     
    end

    it "redirects to the users list" do 
      BankExtract.stub(:find).with(be.id.to_s).and_return(be)
      delete :destroy, { bank_account_id: ba.id, :id => be.id}, valid_session
       response.should redirect_to bank_account_bank_extracts_url(ba)
    end
  end

end

