# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganismsController do

  describe 'GET index' do

    it 'should reset session' do
      session[:period] = 3
      get :index
      session[:period].should == nil
    end
    
    context 'whithout Organism' do
      it 'should redirect to admin new if no organism' do
        Organism.stub(:count).and_return(0)
        get :index
        response.should redirect_to new_admin_organism_path
      end
    end

    context "with one organism" do
      let(:s) {mock_model(Organism)}

      before(:each) do
        Organism.stub(:count).and_return(1)
        Organism.stub(:all).and_return([s])
        Organism.stub(:first).and_return(s)
      end

      it "assigne @organisms" do
        get :index
        assigns[:organisms].should == Organism.all
      end


      it 'when 1 organism, redirect to show' do
        get :index
        response.should redirect_to organism_path(s.id)
      end

    end

    context "with several organisms" do
      let(:s1) {mock_model(Organism)}
      let(:s2) {mock_model(Organism)}

      before(:each) do
        Organism.stub(:count).and_return(2)
        Organism.stub(:all).and_return([s1, s2])
        Organism.stub(:first).and_return(s1)
      end

      it 'assign @organims ' do
        get :index
        assigns[:organisms].should == [s1, s2]
      end

      it 'does not assign @organim ' do
        get :index
        assigns[:organism].should == nil
      end

      it 'render index' do
        get :index
        response.should render_template('index')
      end

    end

  end

  describe 'GET show' do

    let(:o) {mock_model(Organism, name: 'Spec Firm')}
    let(:p) {mock_model(Period, :start_date=>Date.civil(2012,1,1), :close_date=>Date.civil(2012,12,31))}
    let(:c) {mock_model(Cash)}
    let(:ba1) {mock_model(BankAccount)}
    let(:ib) {mock_model(IncomeBook) }
    let(:ob) {mock_model(OutcomeBook) }

    before(:each) do
      Organism.stub(:find).and_return(o)
      o.stub(:periods).and_return([p])
      o.stub_chain(:bank_accounts, :all).and_return([ba1])
      o.stub_chain(:cashes, :all).and_return([c])
      o.stub_chain(:books, :all).and_return([ib,ob])
      o.stub_chain(:periods, :empty?).and_return(false)
      o.stub_chain(:periods, :order, :last, :id).and_return(p.id)
      ba1.stub(:bank_extracts).and_return([])
      Period.stub(:find).with(p.id).and_return(p)
    end
    
    it 'doit rendre la vue show' do
      get :show, :id=>o.id
      response.should render_template('show')
    end

    it 'doit assigner l organisme' do
      get :show, :id=>o.id
      assigns(:organism).should == o
    end

    it 'period doit être recherché par la session' do
      session[:period] = p.id
      o.stub_chain(:periods, :find).with(p.id).and_return(p)
      get :show, :id=>o.id
      assigns(:period).should == p
    end

    it "si pas de session alors period est la dernière" do
      session[:period]=nil
      o.stub_chain(:periods, :find).with(nil).and_raise('error')
      o.stub_chain(:periods, :last).and_return(p)
      get :show, :id=>o.id
      assigns(:period).should == p
      session[:period].should == p.id

    end

    it 'assign l array pave' do
      get :show, :id=>o.id
      assigns[:paves].should be_an_instance_of(Array)
    end

    it 'paves doit avoir 4 éléments' do
      # income et outcomme books, résultat, cash, mais pas bank_account car il n(y a pas de bak_extract
      get :show, :id=>o.id
      assigns[:paves].size.should == 4
    end

    it 'lorsque bank_account a un bank_extract il y a 5 pavés' do
      ba1.stub_chain(:bank_extracts, :any?).and_return(true)
      get :show, :id=>o.id
      assigns[:paves].size.should == 5
    end


  end

end
