# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 # c.filter = {wip:true}
end

describe CheckDepositsController do 
  include SpecControllerHelper

  let(:ba) {mock_model(BankAccount, name: 'IBAN', number: '124578A', organism_id:@o.id)}
  let(:ba2) {mock_model(BankAccount, name: 'IBAN', number: '124578B', organism_id:@o.id)}
  let(:be) {mock_model(BankExtract, bank_account_id: ba.id, begin_date: Date.today.beginning_of_month, end_date: Date.today.end_of_month,
      begin_sold: 120, debit: 450, credit: 1000, end_sold: 120+1000-450)}
  
  
  let(:cd) {mock_model(CheckDeposit)}

  
before(:each) do
   minimal_instances
  @o.stub_chain(:bank_accounts, :find).with(ba.id.to_s).and_return ba
  end

  describe "GET index" do

    context "no pending_checks" do

      before(:each) do
        CheckDeposit.stub!(:pending_checks).and_return nil # juste pour satisfaire le filtre find_non_deposited_checks
        CheckDeposit.stub!(:total_to_pick).and_return 0
        CheckDeposit.stub!(:nb_to_pick).and_return 0
        ba.stub(:check_deposits).and_return @a = double(Arel)
      end

      it "vérification de l'initialisation" do
        ba.stub_chain(:check_deposits, :within_period).and_return [1,2]
        get :index, {:bank_account_id=>ba.id, :organism_id=>@o.id.to_s}, valid_session
        assigns[:period].should == @p
        assigns[:organism].should == @o
        assigns[:bank_account].should == ba
        assigns(:check_deposits).should == [1,2] 
      end

      

      it "bank_account doit recevoir la requête check_deposits et wihtin_period" do
        ba.should_receive(:check_deposits).and_return bac = double(Arel)
        bac.should_receive(:within_period).with(@p.start_date, @p.close_date).and_return []
        get :index, {:bank_account_id=>ba.id,  :organism_id=>@o.id.to_s}, valid_session
      end

      it "sans chèques en attente, ne génère pas de flash" do
        ba.stub_chain(:check_deposits, :within_period).and_return [1,2]
        get :index,{ :bank_account_id=>ba.id, :organism_id=>@o.id.to_s}, valid_session
        flash[:notice].should == nil
      end

      it "avec chèque en attente, génère un flash" do
        @a.stub(:within_period).and_return nil
        CheckDeposit.stub!(:pending_checks).and_return [1,2]
        CheckDeposit.stub!(:total_to_pick).and_return 401
        CheckDeposit.stub!(:nb_to_pick).and_return 2
        get :index,{ :bank_account_id=>ba.id, :organism_id=>@o.id.to_s}, valid_session
        flash[:alert].should == "Il reste 2 chèques à remettre à l'encaissement pour un montant de 401,00 €"

      end
     
      it "rend le template index" do
        ba.stub_chain(:check_deposits, :within_period).and_return [1,2]
        get :index, {:bank_account_id=>ba.id,  :organism_id=>@o.id.to_s}, valid_session
        response.should render_template("index")
      end
    end

    
  end # fin de index

  describe 'GET show' do

    before(:each) do
      @o.stub(:pending_checks).and_return [double(ComptaLine)]
    end
  
    it 'should retrieve the value' do
      CheckDeposit.should_receive(:find).with(cd.id.to_s)
      get :show, {:bank_account_id=>ba.id,  :organism_id=>@o.id.to_s, id:cd.id}, valid_session
    end

    it 'should assign the founded value' do
      CheckDeposit.stub(:find).with(cd.id.to_s).and_return 'voilà'
      get :show, {:bank_account_id=>ba.id,  :organism_id=>@o.id.to_s, id:cd.id}, valid_session
      assigns(:check_deposit).should == 'voilà'
    end

    it 'should render template show' do
      CheckDeposit.stub(:find).with(cd.id.to_s).and_return 'voilà'
      get :show, {:bank_account_id=>ba.id,  :organism_id=>@o.id.to_s, id:cd.id}, valid_session
      response.should render_template('show')
    end
    
  end

  describe 'GET edit' do

    before(:each) do
      @o.stub(:pending_checks).and_return [double(ComptaLine)]
    end

    it 'should retrieve the value' do
      CheckDeposit.should_receive(:find).with(cd.id.to_s)
      get :edit, {:bank_account_id=>ba.id,  :organism_id=>@o.id.to_s, id:cd.id}, valid_session
    end

    it 'should assign the founded value' do
      CheckDeposit.stub(:find).with(cd.id.to_s).and_return 'voilà'
      get :edit, {:bank_account_id=>ba.id,  :organism_id=>@o.id.to_s, id:cd.id}, valid_session
      assigns(:check_deposit).should == 'voilà'
    end

    it 'should render template show' do
      CheckDeposit.stub(:find).with(cd.id.to_s).and_return 'voilà'
      get :edit, {:bank_account_id=>ba.id,  :organism_id=>@o.id.to_s, id:cd.id}, valid_session
      response.should render_template('edit')
    end

  end



  describe 'GET new' do

    context 'sans chèques à remettre' do

      before(:each) do
        CheckDeposit.stub!(:pending_checks).and_return nil
        CheckDeposit.stub!(:total_to_pick).and_return 0
        CheckDeposit.stub!(:nb_to_pick).and_return 0
      end

      it 'redirige vers bask et établit le flash d alerte' do
        controller.should_receive(:redirect_to).with(:back, alert:"Il n'y a pas de chèque à remettre")
        get :new, {:bank_account_id=>ba.id,  :organism_id=>@o.id.to_s}, valid_session
      end

    end

    context 'avec des chèques à remettre'  do
      before(:each) do
        CheckDeposit.stub!(:pending_checks).and_return [double(ComptaLine)]
        CheckDeposit.stub!(:total_to_pick).and_return 100
        CheckDeposit.stub!(:nb_to_pick).and_return 1
      end


     it 'le params de bank_account_id est fixé et utilisé pour check_deposit' do
        CheckDeposit.stub(:new).and_return @cd = mock_model(CheckDeposit).as_new_record
        @o.stub_chain(:bank_accounts, :find).and_return ba2
        ba2.should_receive(:check_deposits).and_return(@a = double(Arel))
        @a.should_receive(:new).and_return(@cd = mock_model( CheckDeposit, :bank_account_id=>ba2.id).as_new_record)
        @cd.should_receive(:pick_all_checks)
        get :new, {:bank_account_id=>ba2.id,  :organism_id=>@o.id.to_s }, valid_session
      end

      context 'new est bien reçu' do

        before(:each) do
          CheckDeposit.stub(:new).and_return @cd = mock_model(CheckDeposit).as_new_record
          @o.stub_chain(:bank_accounts, :first).and_return ba
        end



        it 'rend la vue new' do
          ba.stub_chain(:check_deposits, :new).and_return(@cd = mock_model( CheckDeposit, :bank_account_id=>ba.id).as_new_record)
          @cd.stub(:pick_all_checks)
          get :new, {:organism_id=>@o.id.to_s, :bank_account_id=>ba.id}, valid_session
          response.should render_template('new') 

        end

        it 'assigns check_deposit' do
          ba.stub_chain(:check_deposits, :new).and_return(@cd = mock_model( CheckDeposit, :bank_account_id=>ba.id).as_new_record)
          @cd.stub(:pick_all_checks)
          get :new, {:organism_id=>@o.id.to_s, :bank_account_id=>ba.id}, valid_session
          assigns(:check_deposit).should == @cd
        end
      end
    end

  end




  describe 'GET create' do


    it 'bank_account create a check_deposit and try to save it' do
      ba.should_receive(:check_deposits).and_return @a = double(Arel)
      @a.should_receive(:new).with({"param"=>'value'}).and_return(@cd=mock_model(CheckDeposit))
      @cd.should_receive(:save).and_return true
      post :create, {:bank_account_id=>ba.id, :organism_id=>@o.id.to_s,
          :check_deposit=>{param:'value'} }, valid_session
    end

    it  "when check_deposit is valid" do
      ba.stub_chain(:check_deposits, :new).and_return @cd=mock_model(CheckDeposit)
      @cd.stub(:save).and_return true
      post :create, {:bank_account_id=>ba.id, :organism_id=>@o.id.to_s,
          :check_deposit=>{param:'value'} }, valid_session
      response.should redirect_to organism_bank_account_check_deposits_url(@o, ba)
    end

    it 'when invalid' do
      ba.stub_chain(:check_deposits, :new).and_return @cd=mock_model(CheckDeposit)
      @cd.stub(:save).and_return false
      post :create, {:bank_account_id=>ba.id, :organism_id=>@o.id.to_s,
          :check_deposit=>{param:'value'} }, valid_session
      response.should render_template('new')
    end
    
  end

  describe 'GET update' do

    it 'bank_account create a check_deposit and try to save it' do
      CheckDeposit.should_receive(:find).with(cd.id.to_s).and_return cd
      cd.should_receive(:update_attributes).and_return true
      post :update, {:bank_account_id=>ba.id, :organism_id=>@o.id.to_s, id:cd.id,
          :check_deposit=>{param:'value'} }, valid_session
    end

    it  "when check_deposit is valid" do
      CheckDeposit.stub(:find).with(cd.id.to_s).and_return cd
      cd.stub(:update_attributes).and_return true
      post :update, {:bank_account_id=>ba.id, :organism_id=>@o.id.to_s, id:cd.id,
          :check_deposit=>{param:'value'} }, valid_session
      response.should redirect_to organism_bank_account_check_deposits_url(@o, ba)
    end

    it 'when invalid' do
      CheckDeposit.stub(:find).with(cd.id.to_s).and_return cd
      cd.stub(:update_attributes).and_return false
      post :update, {:bank_account_id=>ba.id, :organism_id=>@o.id.to_s, id:cd.id,
          :check_deposit=>{param:'value'} }, valid_session
      response.should render_template('edit')
    end

  end

  describe "DELETE destroy" do

     it "should look_for the check_deposit" do
      CheckDeposit.should_receive(:find).with(cd.id.to_s).and_return cd
      cd.should_receive(:destroy)
      delete :destroy, { organism_id:@o.id, bank_account_id: ba.id, :id => cd.id}, valid_session

    end

    it "redirects to the index" do
      CheckDeposit.stub(:find).with(cd.id.to_s).and_return cd
      cd.stub(:destroy)
      delete :destroy, { organism_id:@o.id, bank_account_id: ba.id, :id => cd.id}, valid_session
       response.should redirect_to organism_bank_account_check_deposits_url
    end
  end


end