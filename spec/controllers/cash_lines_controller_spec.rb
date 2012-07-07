# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CashLinesController do
  include OrganismFixture
 
  def current_month
   '%02d' % Date.today.month
  end

  def current_year
    '%04d' % Date.today.year
  end

  before(:each) do
    # méthode définie dans OrganismFixture et 
    # permettant d'avoir les variables d'instances @organism, @period, 
    # income et outcome book ainsi qu'une nature
    create_minimal_organism  
  end

  
  describe 'GET index' do
    it "should find the right cash" do
      get :index, {:cash_id=>@c.id, :mois=>current_month, :an=>current_year}, {:period=>@p.id}
      assigns[:cash].should == @c
    end

    it 'should assign organism' do
      get :index, {:cash_id=>@c.id, :mois=>current_month, :an=>current_year}, {:period=>@p.id}
      assigns[:organism].should == @o
    end

  
    it "should create a monthly_book_extract" do
      pending 'bizarre à revoir quand les autres spec seront faites'
      Utilities::MonthlyCashExtract.should_receive(:new).with(@c,  :year=>current_year, :month=>current_month )
      get :index, {:cash_id=>@c.id, :mois=>current_month, :an=>current_year}, {:period=>@p.id} # ce dernier hash pour la session
      assigns[:mois].should == "#{current_month}"
      
    end

    it "should call the filter" do
      pending 'a revoir avec current year'
      @controller.should_not_receive(:fill_natures)
      @controller.should_receive(:change_period)
      get :index, {:cash_id=>@c.id, :mois=>'04', :an=>current_year}, {:period=>@p.id}
    end

    
    it "should render index view" do
       get :index, {:cash_id=>@c.id, :mois=>'04', :an=>'2012'}, {:period=>@p.id}
      response.should render_template(:index)
    end

    it 'traiter le cas ou mois n est pas rempli' do
      get :index,{:cash_id=>@c.id}, {:period=>@p.id}
      response.should redirect_to(cash_cash_lines_path(@c, :mois=>current_month, :an=>current_year))
    end
  end
 
end

