# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PeriodsController do

  describe 'GET new' do

    context "with a stub organism" do

    let(:o) {stub_model(Organism)}

    before(:each) do
      ActiveRecord::Base.stub!(:use_org_connection).and_return(true)  # pour éviter
    # l'appel d'establish_connection dans le before_filter find_organism
      Organism.should_receive(:find).with(o.id.to_s).and_return(o)
    end

    it "controller name should be period" do
      get :new , :organism_id=>o.id
      controller.controller_name.should == 'periods'
    end
  
    it "render new template" do
      get :new , :organism_id=>o.id
      response.should render_template(:new)
    end

    context "when no period, build the new period" do
      it "with start_date equal to beginning_of_year" do
        get :new , :organism_id=>o.id
        assigns[:period].start_date.should == Date.today.beginning_of_year
      end

      it 'with close_date equal to end_of_year' do
        get :new , :organism_id=>o.id
        assigns[:period].close_date.should == Date.today.end_of_year
      end

    end

    end

    context "with a databased organism and a previous period" do
  

      before(:each) do
        @o = Organism.create!(:title=>'Essai')
        @p = @o.periods.create!(:start_date=>Date.today.years_ago(1).beginning_of_year, :close_date=>Date.today.years_ago(1).end_of_year)
      end

      it 'disable_start_date should be true' do
        get :new , :organism_id=>@o.id
        assigns[:disable_start_date].should == true
      end

      it "begin_year is this year" do
        get :new , :organism_id=>@o.id
        assigns[:begin_year].should == Date.today.year
      end

      it "end_year is limited to 2 years" do
        get :new , :organism_id=>@o.id
        assigns[:end_year].should == Date.today.year + 2 
      end
    end



  end
end

