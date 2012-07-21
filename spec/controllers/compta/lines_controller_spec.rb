# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Compta::LinesController do
  let(:a) {mock_model(Account)}

  before(:each) do
    Account.stub(:find).with(a.id.to_s).and_return a
  end

  it "verif a" do
    a.should be_an_instance_of(Account)
    Account.find(a.id.to_s).should == a
  end 

  describe "GET index"  do
    it "get account with params[:account_id] and assigns @account" do
      a.stub_chain(:lines, :range_date).and_return ['un', 'deux']
      controller.stub(:fill_soldes).and_return nil
      get :index, :account_id=>a.id.to_s 
      assigns(:account).should eq(a) 
    end
    it "get lines with params from and to_date ans assigns @lines" do
      a.should_receive(:lines).and_return ls = double(Arel)
      ls.should_receive(:range_date).with('d1','d2').and_return ['un', 'deux']
      controller.stub(:fill_soldes).and_return nil
      get :index, :account_id=>a.id.to_s , :from_date=>'d1', :to_date=>'d2'
      assigns(:lines).should ==  ['un', 'deux']

    end
    it "assigns form_date and to_date with params" do
      a.stub_chain(:lines, :range_date).and_return ['un', 'deux']
      controller.stub(:fill_soldes).and_return nil
      get :index, :account_id=>a.id.to_s, :from_date=>'d1', :to_date=>'d2'
      assigns(:from_date).should eq('d1')
      assigns(:to_date).should eq('d2')
    end

    it "fill solds assigns five instance variables" do
      a.stub(:lines).and_return ls = double(Arel)
      ls.stub(:range_date).and_return [9, 13]
      ls.should_receive(:solde_debit_avant).with('d1').and_return 1
      ls.should_receive(:solde_credit_avant).with('d1').and_return 2
          
      get :index, :account_id=>a.id.to_s, :from_date=>'d1', :to_date=>'d2'
      assigns(:solde_debit_avant).should == 1
      assigns(:solde_credit_avant).should == 2
      assigns(:total_debit).should == 22
      assigns(:total_credit).should == 22
      assigns(:solde).should == 1
    end
 
    it "renders view index" do
      a.stub_chain(:lines, :range_date).and_return ['un', 'deux']
      controller.stub(:fill_soldes).and_return nil
      get :index, :account_id=>a.id.to_s
      response.should render_template("index")
    end
  end

  describe 'GET new' do


    it 'render template new' do
      get :new,  :account_id=>a.id.to_s
      assigns(:account).should == a
      response.should render_template("new")
    end
  end

end

