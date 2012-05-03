# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BankExtractsController do

  
  let(:o)  {mock_model(Organism, title: 'The Small Firm')}
  let(:p)  {mock_model(Period, start_date: Date.civil(2012,01,01), organism_id: o.id, close_date: Date.civil(2012,12,31))}
  let(:ba) {mock_model(BankAccount, name: 'IBAN', number: '124578A', organism_id: o.id)}
  let(:be) {mock_model(BankExtract, bank_account_id: ba.id, begin_date: Date.civil(2012,01,01), end_date: Date.civil(2012,01,31),
      begin_sold: 120, debit: 450, credit: 1000)}
  let(:arr) {double(Arel)}
  let(:brr) {double(Arel)}

 

  before(:each) do
    BankAccount.stub!(:find).and_return(ba)
    Organism.stub!(:find).with(o.id.to_s).and_return(o)
    o.stub_chain(:periods, :order, :last, :id).and_return(p.id)
    Period.stub(:find).with(p.id).and_return(p)
    o.stub_chain(:periods, :any?).and_return true
  end

  describe "GET index" do
    it "sélectionne les extraits correspondant à l'exercice et les assigns à @bank_extracts" do
      ba.should_receive(:bank_extracts).and_return(arr)
      arr.should_receive(:period).and_return(brr)
      brr.should_receive(:all).and_return([be])
      get :index, :organism_id=>o.id.to_s, bank_account_id: ba.id.to_s
      # FIXME this assigns raise an error when written should == p
      assigns(:period).should == p
      assigns(:bank_extracts).should == [be]
    end
  end

  describe "GET show" do
    before(:each) do
      # ici création de quelques bank_extract_lines
      @bel_table= 10.times.map {|t| mock_model(BankExtractLine)}
    end

    it "assigns the requested bank_extract as @bank_extract" do
      BankExtract.should_receive(:find).with(be.id.to_s).and_return(be)
      be.should_receive(:bank_extract_lines).and_return(arr)
      arr.should_receive(:order).with(:position).and_return(@bel_table)
      get :show, :organism_id=>o.id.to_s, bank_account_id: ba.id.to_s, id: be.id.to_s
      assigns(:bank_extract).should == be
      assigns(:bank_extract_lines).should == @bel_table
      assigns(:period).should_not be_nil
    end
  end
#
#  describe "GET new" do
#    it "assigns a new user as @user" do
#      get :new
#      assigns(:user).should be_a_new(User)
#    end
#  end
#
#  describe "GET edit" do
#    it "assigns the requested user as @user" do
#      user = User.create! valid_attributes
#      get :edit, :id => user.id.to_s
#      assigns(:user).should eq(user)
#    end
#  end
#
#  describe "POST create" do
#    describe "with valid params" do
#      it "creates a new User" do
#        expect {
#          post :create, :user => valid_attributes
#        }.to change(User, :count).by(1)
#      end
#
#      it "assigns a newly created user as @user" do
#        post :create, :user => valid_attributes
#        assigns(:user).should be_a(User)
#        assigns(:user).should be_persisted
#      end
#
#      it "redirects to the created user" do
#        post :create, :user => valid_attributes
#        response.should redirect_to(User.last)
#      end
#    end
#
#    describe "with invalid params" do
#      it "assigns a newly created but unsaved user as @user" do
#        # Trigger the behavior that occurs when invalid params are submitted
#        User.any_instance.stub(:save).and_return(false)
#        post :create, :user => {}
#        assigns(:user).should be_a_new(User)
#      end
#
#      it "re-renders the 'new' template" do
#        # Trigger the behavior that occurs when invalid params are submitted
#        User.any_instance.stub(:save).and_return(false)
#        post :create, :user => {}
#        response.should render_template("new")
#      end
#    end
#  end
#
#  describe "PUT update" do
#    describe "with valid params" do
#      it "updates the requested user" do
#        user = User.create! valid_attributes
#        # Assuming there are no other users in the database, this
#        # specifies that the User created on the previous line
#        # receives the :update_attributes message with whatever params are
#        # submitted in the request.
#        User.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
#        put :update, :id => user.id, :user => {'these' => 'params'}
#      end
#
#      it "assigns the requested user as @user" do
#        user = User.create! valid_attributes
#        put :update, :id => user.id, :user => valid_attributes
#        assigns(:user).should eq(user)
#      end
#
#      it "redirects to the user" do
#        user = User.create! valid_attributes
#        put :update, :id => user.id, :user => valid_attributes
#        response.should redirect_to(user)
#      end
#    end
#
#    describe "with invalid params" do
#      it "assigns the user as @user" do
#        user = User.create! valid_attributes
#        # Trigger the behavior that occurs when invalid params are submitted
#        User.any_instance.stub(:save).and_return(false)
#        put :update, :id => user.id.to_s, :user => {}
#        assigns(:user).should eq(user)
#      end
#
#      it "re-renders the 'edit' template" do
#        user = User.create! valid_attributes
#        # Trigger the behavior that occurs when invalid params are submitted
#        User.any_instance.stub(:save).and_return(false)
#        put :update, :id => user.id.to_s, :user => {}
#        response.should render_template("edit")
#      end
#    end
#  end
#
#  describe "DELETE destroy" do
#    it "destroys the requested user" do
#      user = User.create! valid_attributes
#      expect {
#        delete :destroy, :id => user.id.to_s
#      }.to change(User, :count).by(-1)
#    end
#
#    it "redirects to the users list" do
#      user = User.create! valid_attributes
#      delete :destroy, :id => user.id.to_s
#      response.should redirect_to(users_url)
#    end
#  end

end

