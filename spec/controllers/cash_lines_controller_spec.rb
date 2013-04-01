# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CashLinesController do

  include SpecControllerHelper  

  let(:ca) {mock_model(Cash, :organism=>@o, :name=>'Magasin')}
  let(:ccs) { [ mock_model(CashControl, :date=>Date.today, amount: 3, :locked=>false),
      mock_model(CashControl, :date=>Date.today - 1.day, amount: 1, :locked=>false) ] }  
  
  
  def current_month
   '%02d' % Date.today.month 
  end

  def current_year
    '%04d' % Date.today.year
  end

  

  before(:each) do
    minimal_instances
    Cash.stub(:find).with(ca.to_param).and_return(ca)
    ca.stub_chain(:organism, :find_period).and_return @p
  end

  
  describe 'GET index' do

     before(:each) do
       @p.stub_chain(:list_months, :include?).and_return true 
     end


    it "should find the right cash" do
      get :index, {:cash_id=>ca.to_param, :mois=>current_month, :an=>current_year}, valid_session
      assigns[:cash].should == ca
      assigns[:period].should == @p  
    end

    it "should create a monthly_book_extract" do
      Utilities::MonthlyCashExtract.should_receive(:new).with(ca,  :year=>current_year, :month=>current_month )
      get :index, {:cash_id=>ca.to_param, :mois=>current_month, :an=>current_year}, valid_session
    end

    it "should call the filter" do
      controller.should_not_receive(:fill_natures)
      Cash.should_receive(:find).with(ca.to_param).and_return ca
      controller.should_receive(:fill_mois)
      get :index, {:cash_id=>ca.to_param, :mois=>current_month, :an=>current_year}, valid_session
    end

    
    it "should render index view" do
       get :index, {:cash_id=>ca.to_param, :mois=>current_month, :an=>current_year}, valid_session
      response.should render_template(:index)
    end

    it 'traiter le cas ou mois n est pas rempli' do
      @p.should_receive(:guess_month).and_return(MonthYear.from_date(Date.today))
      get :index,{ :cash_id=>ca.to_param }, valid_session
      response.should redirect_to(cash_cash_lines_url(ca.id, :mois=>current_month, :an=>current_year))
    end
  end
 
end

