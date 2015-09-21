# coding: utf-8

require 'spec_helper'
require 'support/spec_controller_helper'

RSpec.configure do |c|
  #  c.filter = {:wip=>true}
end


describe BankExtractsController do
  include SpecControllerHelper


  let(:ba) {stub_model(BankAccount, name: 'IBAN', number: '124578A', organism_id: @o.id)}
  let(:be) {mock_model(BankExtract, bank_account_id: ba.id, begin_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month,
                       begin_sold: 120, debit: 450, credit: 1000, end_sold: 120+1000-450)}


  def valid_params
    {"bank_account_id"=>ba.to_param,  "begin_sold"=>be.end_sold.to_s,
     "total_debit"=> 11.to_s, "total_credit"=> 37.to_s , "begin_date_picker"=> '01/05/2012',
     "end_date_picker"=> '31/05/2012' }
  end


  before(:each) do
    minimal_instances
    BankAccount.stub(:find).and_return(ba)

  end

  describe "GET index" do
    it "sélectionne les extraits correspondant à l'exercice et les assigns à @bank_extracts" do
      ba.stub_chain(:bank_extracts, :period, :to_a).and_return([be])
      get :index,{:organism_id=>@o.to_param, bank_account_id: ba.to_param}, valid_session
      assigns[:period].should == @p
      assigns[:bank_extracts].should == [be]
    end
  end


  describe "GET new" do
    before(:each) do
      @new_bank_extract = ba.bank_extracts.new
      ba.stub(:new_bank_extract).and_return(@new_bank_extract)
    end


    it "assigns bank_extract" do
      get :new, {:organism_id=>@o.to_param, bank_account_id: ba.to_param}, valid_session
      assigns(:bank_extract).should == @new_bank_extract
    end

    it "renders new template" do
      get :new,{ :organism_id=>@o.to_param, bank_account_id: ba.to_param}, valid_session
      response.should render_template 'new'
    end

    it 'mais redirige vers index si on ne peut pas créer un nouvel extrait' do
      ba.stub(:new_bank_extract).and_return nil
      get :new,{ :organism_id=>@o.to_param, bank_account_id: ba.to_param}, valid_session
      response.should redirect_to(bank_account_bank_extracts_url(ba))
    end
  end

  describe 'GET lines_to_point' , wip:true do




    it 'rend le template lines_to_point' do
      get :lines_to_point, {:bank_account_id=>ba.to_param}, valid_session
      response.should render_template 'lines_to_point'
    end

    it 'assigns @lines_to_point' do
      ba.should_receive(:not_pointed_lines).and_return 'bonjour'
      get :lines_to_point, {:bank_account_id=>ba.to_param}, valid_session
      assigns(:lines_to_point).should == 'bonjour'
    end

  end

  describe "GET edit" do

    it "assigns the requested bank_extract as @bank_extract" do
      BankExtract.should_receive(:find).with(be.to_param).and_return be
      get :edit, {:organism_id=>@o.to_param, bank_account_id: ba.to_param, :id=>be.id}, valid_session
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

    it 'redirige vers imported_bels s il y en a' do
      ba.stub_chain(:imported_bels, :empty?).and_return false
      @be.stub(:save).and_return true
      post :create,{ :organism_id=>@o.id, :bank_account_id=> ba.id,
                     :bank_extract => valid_params}, valid_session
      response.should redirect_to bank_account_imported_bels_url(ba)
    end


    it "re-renders the 'new' template" do
      @be.stub(:save).and_return false
      post :create,{ :organism_id=>@o.id, :bank_account_id=> ba.id,
                     :bank_extract => valid_params}, valid_session
      response.should render_template("new")
    end

  end


  describe "POST lock" , wip:true do
    it 'cherche le bank_extract' do
      BankExtract.should_receive(:find).with(be.to_param).and_return(@be = mock_model(BankExtract, 'locked='=>true, :save=>true))

      post :lock,{ :bank_account_id=> ba.id,
                   :id => be.to_param}, valid_session
    end

    it 'met locked à true' do
      BankExtract.stub(:find).and_return(@be = mock_model(BankExtract, :save=>true))
      @be.should_receive('locked=').with(true).and_return true
      post :lock,{ :bank_account_id=> ba.id, :id => be.to_param}, valid_session
    end

    it 'puis sauve' do
      BankExtract.stub(:find).and_return(@be = mock_model(BankExtract, 'locked='=>true))
      @be.should_receive(:save).and_return true
      post :lock,{ :bank_account_id=> ba.id, :id => be.to_param}, valid_session
      flash[:notice].should == 'Relevé validé et verrouillé'
    end

    it 'en cas d echec affiche un alert' do
      BankExtract.stub(:find).and_return(@be = mock_model(BankExtract, 'locked='=>true))
      @be.should_receive(:save).and_return false
      post :lock,{ :bank_account_id=> ba.id, :id => be.to_param}, valid_session
      flash[:alert].should == "Une erreur n'a pas permis de valider le relevé"
    end
  end
  #
  describe "PUT update" do


    before(:each) do
      BankExtract.any_instance.stub(:fill_bank_extract_lines).and_return(nil)
    end

    it "should look for bank_extract and assigns it" do
      BankExtract.should_receive(:find).with(be.to_param).and_return be
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
      BankExtract.should_receive(:find).with(be.to_param).and_return(be)
      delete :destroy, { bank_account_id: ba.id, :id => be.id}, valid_session

    end

    it "redirects to the users list" do
      BankExtract.stub(:find).with(be.to_param).and_return(be)
      delete :destroy, { bank_account_id: ba.id, :id => be.id}, valid_session
      response.should redirect_to bank_account_bank_extracts_url(ba)
    end
  end

end

