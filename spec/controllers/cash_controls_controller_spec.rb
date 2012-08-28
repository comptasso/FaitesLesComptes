# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
 #   c.filter = {:wip => true }
  #  c.exclusion_filter = {:js=> true }
end

describe CashControlsController do
   include SpecControllerHelper

  let(:ca) {mock_model(Cash, :organism=>@o, :name=>'Magasin')}
  let(:ccs) { [ mock_model(CashControl, :date=>Date.today, amount: 3, :locked=>false),
      mock_model(CashControl, :date=>Date.today - 1.day, amount: 1, :locked=>false) ] }
  
  
  before(:each) do
    minimal_instances
    

    @m = '%02d' % Date.today.month.to_s
    @y = '%04d' % Date.today.year.to_s
    
    @p.stub(:guess_month).and_return(MonthYear.from_date(Date.today))
    
  end

 

  
  describe 'GET index'  do

    before(:each) do
      Cash.should_receive(:find).with(ca.id.to_s).and_return(ca)
       ca.stub_chain(:cash_controls, :monthyear).and_return(ccs)
    end

    it "should find the right cash" do
      get :index, {:cash_id=>ca.id, :mois=>@m, :an=>@y}, valid_session
      assigns[:cash].should == ca 
      assigns[:cash].name.should == 'Magasin'
    end

    it 'should assign organism'  do
      get :index, {:cash_id=>ca.id, :mois=>@m, :an=>@y}, valid_session
      assigns[:organism].should == @o
    end

    it 'should assign cash_controls' do
      get :index, {:cash_id=>ca.id, :mois=>@m, :an=>@y}, valid_session
      assigns[:cash_controls].should == ccs
    end
    
    it 'should assign cash_controls' do
      get :index,{ :cash_id=>ca.id, :mois=>@m, :an=>@y}, valid_session
      response.should render_template 'index'
    end

    it 'without month redirect to url with params month' do
      get :index, {:cash_id=>ca.id}, valid_session
      response.should redirect_to cash_cash_controls_path(ca,:mois=>@m, :an=>@y )
    end

 end

  describe 'GET new' do

    before(:each) do
      ca.should_receive(:cash_controls).and_return(CashControl)
      Cash.should_receive(:find).with(ca.id.to_s).and_return(ca)
      get :new, {:cash_id=>ca.id, :mois=>@m}, valid_session
    end

    it 'assigns a new cash control' do
      assigns[:cash_control].should be_an_instance_of CashControl
    end

    it 'intialized with Date.today' do
      assigns[:cash_control].date.should == Date.today
    end

    it 'and render new view' do
      response.should render_template 'new'
    end

  end

  describe 'POST create' do

    before(:each) do
      Cash.stub(:find).with(ca.id.to_s).and_return(ca)
      ca.stub(:cash_controls).and_return(CashControl)
      CashControl.any_instance.stub(:date_within_limit).and_return(nil)
    end

    it 'shoudl render new when not valid' do
      post :create, {:cash_id=>ca.id, :cash_control=> {date: Date.today}}, valid_session
      response.should render_template 'new'
    end

    it 'should redirect to index' do
      # ici on triche un peu en mettant cash_id comme paramètre, encore que, pas sur
      post :create,{ :cash_id=>ca.id, :cash_control=> {:date=>Date.today, :amount=>5, :cash_id=>ca.id }}, valid_session
      response.should redirect_to cash_cash_controls_path(ca, :mois=>@m, :an=>@y)

    end

  end

  describe 'GET edit' do

    before(:each) do
      Cash.stub(:find).with(ca.id.to_s).and_return(ca)
      ca.stub(:cash_controls).and_return(ccs)
      ccs.stub(:find).and_return(ccs.first)
      @cash_control = ccs.first
    end

    it 'render edit' do
      
      get :edit,{ cash_id: ca.id, id: @cash_control.id}, valid_session
      response.should render_template 'edit'
    end

    it 'assigns cash control' do
      get :edit,{ cash_id: ca.id, id: @cash_control.id}, valid_session
      assigns[:cash_control].should == @cash_control
    end


  end

  describe 'PUT create' do

    before(:each) do
      Cash.stub(:find).with(ca.id.to_s).and_return(ca)
      ca.stub(:cash_controls).and_return(CashControl)

      @cash_control = ccs.first
      CashControl.stub(:find).and_return @cash_control
    end

    it 'redirect_to index when updates all_right' do
      mois = (Date.today.month) - 1
      @cash_control.should_receive(:update_attributes).and_return true
      put :update,{ cash_id: ca.id, id: @cash_control.id, cash_control: {date: Date.today - 3.day, amount: 100, cash_id: ca.id}}, valid_session
      response.should redirect_to cash_cash_controls_path(ca, :mois=>@m, :an=>@y)
    end

    it 'but rerender when update_attributes echoue' do
      @cash_control.should_receive(:update_attributes).and_return false
      put :update,{ cash_id: ca.id, id: @cash_control.id, cash_control: {date: Date.today - 3.day, amount: 100, cash_id: ca.id}}, valid_session
      response.should render_template 'edit' 
    end

  end

  describe 'POST lock' do
    before(:each) do
      Cash.stub(:find).with(ca.id.to_s).and_return(ca)
      ca.stub(:cash_controls).and_return(CashControl)
      @cash_control = ccs.first
      CashControl.stub(:find).and_return @cash_control
    end

    it 'when locked is successful' do
      @cash_control.should_receive(:locked=).and_return(true)
      @cash_control.should_receive(:save).and_return(true)
      post :lock,{ cash_id: ca.id, id: @cash_control.id}, valid_session
      flash[:notice].should == 'Le contrôle a été verrouillé ainsi que les lignes correspondantes'
    end

    it 'when lock fails' do
      @cash_control.should_receive(:locked=).and_return(true)
      @cash_control.should_receive(:save).and_return(false)
      post :lock, {cash_id: ca.id, id: @cash_control.id}, valid_session
      flash[:alert].should == "Une erreur s'est produite et n'a pas permis de verrouiller le contrôle de caisse"
    end

    it 'dans les deux cas redirige vers l action index' do
      mois = (Date.today.month) - 1
      @cash_control.should_receive(:locked=).and_return(true)
      @cash_control.should_receive(:save).and_return(true)
      post :lock, {cash_id: ca.id, id: @cash_control.id}, valid_session
      response.should redirect_to cash_cash_controls_url(ca, mois:@m, an:@y)
    end


  end

  

  

  

 

  
end

