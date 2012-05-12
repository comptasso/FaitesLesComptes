# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BankExtractsController do

  
  let(:o)  {mock_model(Organism, title: 'The Small Firm')}
  let(:per) {mock_model(Period, :organism=>o, :star_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year, :guess_month=>Date.today.month - 1)}
  let(:ba) {mock_model(BankAccount, name: 'IBAN', number: '124578A', organism_id: o.id)}
  let(:be) {mock_model(BankExtract, bank_account_id: ba.id, begin_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month,
      begin_sold: 120, debit: 450, credit: 1000, end_sold: 120+1000-450)}
  let(:arr) {double(Arel)}
  let(:brr) {double(Arel)}

 

  before(:each) do
    BankAccount.stub!(:find).and_return(ba)
    Organism.stub!(:find).and_return(o)
    Period.stub!(:find).and_return(per)
    o.stub_chain(:periods, :order, :last).and_return(per)
    o.stub_chain(:periods, :any?).and_return true
  end

  describe "GET index" do
    it "sélectionne les extraits correspondant à l'exercice et les assigns à @bank_extracts" do
      ba.stub_chain(:bank_extracts, :period, :all).and_return([be])
      get :index, :organism_id=>o.id.to_s, bank_account_id: ba.id.to_s
      assigns[:period].should == per
      assigns[:bank_extracts].should == [be]
    end
  end

#  describe "GET show" do
#    before(:each) do
#      # ici création de quelques bank_extract_lines
#      @bel_table= 10.times.map {|t| mock_model(BankExtractLine)}
#    end
#
#    it "assigns the requested bank_extract as @bank_extract" do
#      BankExtract.should_receive(:find).with(be.id.to_s).and_return(be)
#      be.stub_chain(:bank_extract_lines, :order).and_return(@bel_table)
#      get :show, :organism_id=>o.id.to_s, bank_account_id: ba.id.to_s, id: be.id.to_s
#      assigns(:bank_extract).should == be
#      assigns(:bank_extract_lines).should == @bel_table
#      assigns[:period].should == per
#    end
#  end

  describe "GET new" do
    before(:each) do
      @new_bank_extract = BankExtract.new(bank_account_id: ba.id)
      ba.stub(:new_bank_extract).and_return(@new_bank_extract)
    end


    it "assigns bank_extract" do
      get :new, :organism_id=>o.id.to_s, bank_account_id: ba.id.to_s
      assigns(:bank_extract).should == @new_bank_extract
    end

    it "renders new template" do
      get :new, :organism_id=>o.id.to_s, bank_account_id: ba.id.to_s
      response.should render_template 'new'
    end
  end

  describe "GET edit" do

    before(:each) do

    end

    it "assigns the requested user as @user" do
      BankExtract.should_receive(:find).with(be.id.to_s).and_return be
      get :edit, :organism_id=>o.id.to_s, bank_account_id: ba.id.to_s, :id=>be.id
      assigns(:bank_extract).should == be
    end
  end

  describe "POST create" do
    def valid_params
      {bank_account_id: ba.id,  begin_sold: be.end_sold,
        total_debit: 11, total_credit: 37 , begin_date_picker: '01/05/2012',
      end_date_picker: '31/05/2012' }
    end

    before(:each) do
      ba.stub(:bank_extracts).and_return(BankExtract)
      BankExtract.any_instance.stub(:fill_bank_extract_lines).and_return(nil)
    end

    describe "with valid params" do
      it "creates a new BankExtract" do
        expect {
          post :create, :organism_id=>o.id, :bank_account_id=> ba.id,
          :bank_extract => valid_params
        }.to change(BankExtract, :count).by(1)
      end

      it "assigns a newly created bank_extract as @bank_extract" do
        post :create, :organism_id=>o.id, :bank_account_id=> ba.id,
          :bank_extract => valid_params
        assigns(:bank_extract).should be_a(BankExtract)
        assigns(:bank_extract).should be_persisted
      end

      it "redirects to pointage" do
        post :create, :organism_id=>o.id, :bank_account_id=> ba.id,
          :bank_extract => valid_params
        response.should redirect_to organism_bank_account_bank_extracts_url(o, ba)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved bank_account as @bank_account" do
        # Trigger the behavior that occurs when invalid params are submitted
        BankExtract.any_instance.stub(:save).and_return(false)
        post :create, :organism_id=>o.id, :bank_account_id=> ba.id,
          :bank_extract => {}
        assigns(:bank_extract).should be_a_new(BankExtract)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        BankExtract.any_instance.stub(:save).and_return(false)
        post :create, :organism_id=>o.id, :bank_account_id=> ba.id,
          :bank_extract => {}
        response.should render_template("new")
      end
    end
  end
  #
  describe "PUT update" do

    def valid_attributes
      { "bank_account_id"=> ba.id.to_s,  "begin_sold"=>be.end_sold.to_s,
        "total_debit"=> 11.to_s, "total_credit"=> 37.to_s , 
        "begin_date_picker"=> '01/05/2012',
        "end_date_picker"=> '31/05/2012' }
    end

   
    before(:each) do
      BankExtract.any_instance.stub(:fill_bank_extract_lines).and_return(nil)
    end
    
    describe "with valid params" do
      it "updates the requested bank_extract" do
        bank_extract = BankExtract.create! valid_attributes
        # Assuming there are no other users in the database, this
        # specifies that the User created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        BankExtract.any_instance.should_receive(:update_attributes).with(valid_attributes)
        put :update, organism_id: o.id, bank_account_id: ba.id, :id => bank_extract.id, 
          :bank_extract => valid_attributes
      end

      it "assigns the requested user as @user" do
        bank_extract = BankExtract.create! valid_attributes
        put :update, organism_id: o.id, bank_account_id: ba.id, :id => bank_extract.id, :bank_extract => valid_attributes
          
        assigns(:bank_extract).should == bank_extract
      end

      it "redirects to the user" do
        bank_extract = BankExtract.create! valid_attributes
        put :update, organism_id: o.id, bank_account_id: ba.id, :id => bank_extract.id, :bank_extract => valid_attributes
         
        response.should redirect_to organism_bank_account_bank_extracts_url(o, ba)
      end
    end

    describe "with invalid params" do
      it "assigns the bank_extract as @bank_extract" do
        bank_extract = BankExtract.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        BankExtract.any_instance.stub(:save).and_return(false)
        put :update, organism_id: o.id, bank_account_id: ba.id, :id => bank_extract.id, :bank_extract => valid_attributes
          
        assigns(:bank_extract).should == bank_extract
      end

      it "re-renders the 'edit' template" do
        bank_extract = BankExtract.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        BankExtract.any_instance.stub(:save).and_return(false)
        put :update, organism_id: o.id, bank_account_id: ba.id, :id => bank_extract.id, :bank_extract => valid_attributes
         
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do

    def valid_attributes
      { "bank_account_id"=> ba.id.to_s,  "begin_sold"=>be.end_sold.to_s,
        "total_debit"=> 11.to_s, "total_credit"=> 37.to_s , "begin_date"=> be.end_date + 1.day,
        "end_date"=> be.end_date.months_since(1) }
    end
    before(:each) do
      BankExtract.any_instance.stub(:fill_bank_extract_lines).and_return(nil)
    end
    it "destroys the requested bank_extract" do
      bank_extract = BankExtract.create! valid_attributes
      expect {
        delete :destroy,  organism_id: o.id, bank_account_id: ba.id, :id => bank_extract.id.to_s
      }.to change(BankExtract, :count).by(-1)
    end

    it "redirects to the users list" do 
      bank_extract = BankExtract.create! valid_attributes
      delete :destroy,  organism_id: o.id, bank_account_id: ba.id, :id => bank_extract.id.to_s
      response.should redirect_to(organism_bank_account_bank_extracts_url o, ba)
    end
  end

end

