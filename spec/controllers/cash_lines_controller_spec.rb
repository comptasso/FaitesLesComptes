# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CashLinesController do
  include OrganismFixture
 
  # TODO faire également les autres actions de cashLinesController_spec


  def current_month
    (Date.today.month) - 1
  end

  before(:each) do
    # méthode définie dans OrganismFixture et 
    # permettant d'avoir les variables d'instances @organism, @period, 
    # income et outcome book ainsi qu'une nature
    create_minimal_organism  
  end

  
  describe 'GET index' do
    it "should find the right cash" do
      get :index, {:cash_id=>@c.id, :mois=>current_month}, {:period=>@p.id}
      assigns[:cash].should == @c
    end

    it 'should assign organism' do
      get :index, {:cash_id=>@c.id, :mois=>current_month}, {:period=>@p.id}
      assigns[:organism].should == @o
    end

    it "should create a monthly_book_extract" do
      Utilities::MonthlyCashExtract.should_receive(:new).with(@c, @p.start_date.months_since(current_month))
      get :index, {:cash_id=>@c.id, :mois=>current_month}, {:period=>@p.id}
      assigns[:mois].should == "#{current_month}"
      assigns[:date].should == Date.today.beginning_of_month
    end

    it "should call the filter" do
      @controller.should_not_receive(:fill_natures)
      @controller.should_receive(:change_period)
      get :index, {:cash_id=>@c.id, :mois=>'4'}, {:period=>@p.id}
    end

    it "date doit être rempli" do
       get :index, {:cash_id=>@c.id, :mois=>'4'}, {:period=>@p.id}
      assigns[:date].should == Date.civil(2012,5,1)
    end

    it "should render index view" do
       get :index, {:cash_id=>@c.id, :mois=>'4'}, {:period=>@p.id}
      response.should render_template(:index)
    end

    it 'traiter le cas ou mois n est pas rempli' do
      get :index,{:cash_id=>@c.id}, {:period=>@p.id}
      response.should redirect_to(cash_cash_lines_path(@c, :mois=>current_month))
    end
  end
 
end

