# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CashLinesController do

  let(:o) {mock_model(Organism)}
  let(:p) {mock_model(Period, :organism=>o, :start_date=>Date.today.beginning_of_year, :close_date=>Date.today.end_of_year)}

  let(:ca) {mock_model(Cash, :organism=>o, :name=>'Magasin')}
  let(:ccs) { [ mock_model(CashControl, :date=>Date.today, amount: 3, :locked=>false),
      mock_model(CashControl, :date=>Date.today - 1.day, amount: 1, :locked=>false) ] }
  let(:cu) {mock_model(User)}
  
  def current_month
   '%02d' % Date.today.month
  end

  def current_year
    '%04d' % Date.today.year
  end

  def valid_session
    {user:cu.id, period:p.id, org_db:'assotest'}
  end


  before(:each) do
    ActiveRecord::Base.stub!(:use_org_connection).and_return(true)  # pour éviter
    # l'appel d'establish_connection dans le before_filter find_organism

    Organism.stub(:first).and_return(o)
    Period.stub(:find_by_id).with(p.id).and_return p
    Cash.stub(:find).with(ca.id.to_s).and_return ca

    o.stub_chain(:periods, :any?).and_return(true)
     
  end

  
  describe 'GET index' do
    it "should find the right cash" do
      get :index, {:cash_id=>ca.id, :mois=>current_month, :an=>current_year}, valid_session
      assigns[:cash].should == ca
      assigns[:period].should == p
    end

    it "should create a monthly_book_extract" do
      Utilities::MonthlyCashExtract.should_receive(:new).with(ca,  :year=>current_year, :month=>current_month )
      get :index, {:cash_id=>ca.id, :mois=>current_month, :an=>current_year}, valid_session 
      assigns[:mois].should == "#{current_month}"
    end

    it "should call the filter" do
      controller.should_not_receive(:fill_natures)
      controller.should_receive(:find_book)
      controller.should_receive(:fill_mois)
      get :index, {:cash_id=>ca.id, :mois=>'04', :an=>current_year}, valid_session
    end

    
    it "should render index view" do
       get :index, {:cash_id=>ca.id, :mois=>'04', :an=>'2012'}, valid_session
      response.should render_template(:index)
    end

    it 'traiter le cas ou mois n est pas rempli' do
      p.should_receive(:guess_month).and_return(MonthYear.from_date(Date.today))
      get :index,{:cash_id=>ca.id}, valid_session
      response.should redirect_to(cash_cash_lines_url(ca, :mois=>current_month, :an=>current_year))
    end
  end
 
end

