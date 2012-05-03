# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CashLinesController do
   include OrganismFixture
  
  before(:each) do 
    # méthode définie dans OrganismFixture et 
    # permettant d'avoir les variables d'instances @organism, @period, 
    # income et outcome book ainsi qu'une nature
    create_minimal_organism
    @ca = @o.cashes.create!(name: 'Caisse')
  end

  
  describe 'GET index' do
    it "should find the right cash" do
     # controller.should_receive(:find_book)
      get :index, :cash_id=>@ca.id, :mois=>4  
      assigns[:cash].should == @ca
    end

    it 'should assign organism' do
      get :index, :cash_id=>@ca.id, :mois=>4
      assigns[:organism].should == @o
    end

    it "should create a monthly_book_extract" do
      Utilities::MonthlyCashExtract.should_receive(:new).with(@ca, @p.start_date.months_since(4))
      get :index, :cash_id=>@ca.id, :mois=>4
    end

    it "should call the filter" do
      @controller.should_not_receive(:fill_natures)
      @controller.should_receive(:change_period)
      get :index, :cash_id=>@ca.id, :mois=>4
    end

    it "date doit être rempli" do
      get :index, :cash_id=>@ca.id, :mois=>4
      assigns[:date].should == Date.civil(2012,5,1)
    end

    it "should render index view" do
      get :index, :cash_id=>@ca.id, :mois=>4
      response.should render_template(:index)
    end

    it 'traiter le cas ou mois n est pas rempli' do
      m = (Date.today.month)-1
      get :index, :cash_id=>@ca.id
      response.should redirect_to(cash_cash_lines_path(@ca, :mois=>m))
    end
  end

  

  

 

  
end

