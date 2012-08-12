# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  #  c.filter = {:wip=> true }
  #  c.exclusion_filter = {:js=> true }
end


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

  describe 'GET show', :wip=> true do

    let(:o) {mock_model(Organism, name: 'Spec Firm')}
    let(:pe) {mock_model(Period, :start_date=>Date.civil(2012,1,1), :close_date=>Date.civil(2012,12,31))}
    let(:c) {mock_model(Cash)}
    let(:ba1) {mock_model(BankAccount)}
    let(:ib) {mock_model(IncomeBook) }
    let(:ob) {mock_model(OutcomeBook) }

    before(:each) do
      Organism.stub(:find).and_return(o)
      o.stub(:periods).and_return([pe])
      o.stub_chain(:bank_accounts, :all).and_return([ba1])
      o.stub_chain(:cashes, :all).and_return([c])
      o.stub_chain(:books, :all).and_return([ib,ob])
      o.stub_chain(:periods, :empty?).and_return(false)
      o.stub_chain(:periods, :order, :last, :id).and_return(pe.id)
      ba1.stub(:bank_extracts).and_return([])
      Period.stub(:find).with(pe.id).and_return(pe)
    end
    
    it 'doit rendre la vue show' do
      get :show, :id=>o.id
      response.should render_template('show')
    end

    it 'doit assigner l organisme' do
      get :show, :id=>o.id
      assigns(:organism).should == o
    end

    describe 'gestion de la session organism' do
      it 'fill session[:organism]' do
        get :show, :id=>o.id
        session[:organism].should == o.id
      end

      it 'si on réappelle show pour le même organisme on ne change pas la session' do
        session[:organism] = o.id
        get :show, :id=>o.id
        session[:organism].should == o.id
      end

      it 'si on appelle show pour un autre organisme, on change la session' do
        session[:organism] = o.id.to_s
        o2 = stub_model(Organism, title: 'deuxième Organisme')
        Organism.should_receive(:find).with(o2.id.to_s).and_return(o2)
        get :show, :id => o2.id
        session[:organism].should == o2.id
        session[:period].should be_nil
      end

    end


    describe 'gestion de la session period' do 
      it 'period doit être recherché par la session' do
        pending "a revoir car donne une erreur inconnue (pretty print)"
     #   session[:period] = pe.id
     #   o.stub_chain(:periods, :find).with(pe.id).and_return(pe)
        get :show, :id=>o.id
        pe.should be_an_instance_of(Period)
        assigns[:period].should_not be_nil
        assigns[:period].should == pe #be_an_instance_of(Period)
      end

      it "si pas de session alors period est la dernière" do
        pending "a revoir car donne une erreur inconnue (pretty print)"
      #  session[:period]=nil
        o.stub_chain(:periods, :find).with(nil).and_raise('error')
        o.stub_chain(:periods, :last).and_return(pe)
        get :show, :id=>o.id
        response.should render_template('show')
        assigns[:organism].should == o
        assigns[:period].should == pe
#        session[:period].should == pe.id
      end
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
