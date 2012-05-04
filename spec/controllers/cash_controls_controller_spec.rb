# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
 #   c.filter = {:wip => true }
  #  c.exclusion_filter = {:js=> true }
end

describe CashControlsController do
   include OrganismFixture

  let(:o) {mock_model(Organism)}
  let(:p) {mock_model(Period, :organism=>o, :star_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year, :guess_month=>Date.today.month - 1)}

  let(:ca) {mock_model(Cash, :organism=>o)}
  let(:ccs) { [ mock_model(CashControl, :date=>Date.today, amount: 3), mock_model(CashControl, :date=>Date.today - 1.day, amount: 1) ] }
  
  before(:each) do
    @mois = Date.today.month - 1
    o.stub(:periods).and_return { mock(Arel, :order=>[p], 'any?' =>true) }
  end

#  before(:each) do
#    
#  end

  
  describe 'GET index'  do

    before(:each) do
      Cash.should_receive(:find).with(ca.id.to_s).and_return(ca)
       ca.stub_chain(:cash_controls, :mois).and_return(ccs)
    end

    it "should find the right cash" do
      get :index, :cash_id=>ca.id, :mois=>@mois
      assigns[:cash].should == ca
    end

    it 'should assign organism' , :wip => true do
      get :index, :cash_id=>ca.id, :mois=>@mois
      assigns[:organism].should == o
    end

    it 'should assign cash_controls' do
      get :index, :cash_id=>ca.id, :mois=>@mois
      assigns[:cash_controls].should == ccs
    end
    
    it 'should assign cash_controls' do
      get :index, :cash_id=>ca.id, :mois=>@mois
      response.should render_template 'index'
    end

#    it 'test un cash_control' do
#      CashControl.any_instance.stub('jcperiod').and_return(p)
#      get :index, :cash_id=>ca.id, :mois=>@mois
#
#      cc = assigns[:cash_controls].first
#      cc.should be_an_instance_of(CashControl)
#      cc.jcperiod.should == p
#      cc.min_date.should == p.start_date
#    end


  end

  describe 'GET new' do

    before(:each) do
      ca.should_receive(:cash_controls).and_return(CashControl)
      Cash.should_receive(:find).with(ca.id.to_s).and_return(ca)
      get :new, :cash_id=>ca.id, :mois=>@mois
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
      post :create, :cash_id=>ca.id, :cash_control=> {date: Date.today}
      response.should render_template 'new'
    end

    it 'should redirect to index' do
      # ici on triche un peu en mettant cash_id comme paramètre
      post :create, :cash_id=>ca.id, :cash_control=> {:date=>Date.today, :amount=>5, :cash_id=>ca.id }
      response.should redirect_to cash_cash_controls_path(ca, :mois=>@mois) 
 #      assign[:cash_control].min_date.should == p.start_date
    end

  


  end

  

  

  

 

  
end

