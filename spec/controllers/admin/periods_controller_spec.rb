# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PeriodsController do
   include SpecControllerHelper

  def valid_params
    {'start_date'=>Date.today.beginning_of_year.to_formatted_s(:db), 'close_date'=>Date.today.end_of_year.to_formatted_s(:db)}
  end

   before(:each) do
     minimal_instances
   end

  describe 'GET index' do
    before(:each) do
       @o.stub(:periods).and_return [mock_model(Period), mock_model(Period)]

    end

    it 'renden index template' do
      get :index, {organism_id:@o.id}, valid_session
      response.should render_template(:index)
    end
  end

  describe 'POST create' do

    before(:each) do
      @o.stub(:periods).and_return(@a = double(Arel, :find_by_id=>nil))
    end

    it 'rend vue index si tout est OK' do
      @a.should_receive(:new).with(valid_params).and_return mock_model(Period, :save=>true).as_new_record
      post :create, {organism_id:@o.id, :period=>valid_params}, valid_session
      response.should redirect_to admin_organism_periods_url(@o)
    end

    it 'rend la vue edit si erreur dans la sauvegarde' do
      @a.should_receive(:new).with(valid_params).and_return mock_model(Period, :save=>false).as_new_record
      post :create, {organism_id:@o.id, :period=>valid_params}, valid_session
      response.should render_template :new
    end
  end

  describe 'DELETE destroy' do


    it "destroys the requested period" do
      Period.should_receive(:find).with(@p.to_param).and_return(@p)
      delete :destroy, {organism_id:@o.to_param, :id=>@p.to_param}, valid_session

    end

    it "redirects to the period list" do
      Period.should_receive(:find).with(@p.to_param).and_return(@p)
      delete :destroy, {organism_id:@o.to_param, :id=>@p.to_param}, valid_session
      response.should redirect_to(admin_organism_periods_url(@o))
    end
  end

 
  describe 'GET new' do

    context "check the rendering" do

     before(:each) do
       @o.stub_chain(:periods, :new).and_return mock_model(Period)
     end

    it "controller name should be period" do
      get :new , {:organism_id=>@o.id} , valid_session 
      controller.controller_name.should == 'periods'
    end
  
    it "render new template" do
      get :new , {:organism_id=>@o.id} , valid_session
      response.should render_template(:new) 
    end

      end

    context "when no period, build the new period" do
      before(:each) do
       @o.stub(:periods).and_return @a = double(Arel)
       @a.stub(:any?).and_return false
       @a.stub(:empty?).and_return(!(@a.any?))
      end

      it "with start_date equal to beginning_of_year" do
        @a.should_receive(:new).with(start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year).and_return @p
        get :new , {:organism_id=>@o.id} ,  {user:@cu.id, org_db:'assotest'}
        assigns[:period].start_date.should == Date.today.beginning_of_year
      end

      it 'with close_date equal to end_of_year' do
        @a.should_receive(:new).with(start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year).and_return @p
         get :new , {:organism_id=>@o.id} ,  {user:@cu.id, org_db:'assotest'}
        assigns[:period].close_date.should == Date.today.end_of_year
      end

    end

    

    context "with a previous period" do

      def arguments
        b = Date.today.beginning_of_year.years_since(1)
        e = b.end_of_year
        {start_date:b, close_date:e}
      end

      before(:each) do
        @o.stub(:periods).and_return @a = double(Arel)
        @a.stub(:any?).and_return true
        @a.stub(:empty?).and_return(!(@a.any?))
        @a.stub_chain(:last, :close_date).and_return @p.close_date
        @a.stub(:find_by_id).and_return(@p)
      end
  
      it 'disable_start_date should be true' do
        @a.should_receive(:new).with(arguments).and_return mock_model(Period)
        get :new , {:organism_id=>@o.id} , valid_session
        assigns[:disable_start_date].should == true
      end

      it "begin_year is this year" do
        @a.should_receive(:new).with(arguments).and_return mock_model(Period)
        get :new , {:organism_id=>@o.id} ,  valid_session
        assigns[:begin_year].should == (Date.today.year + 1)
      end

      it "end_year is limited to 2 years" do
        @a.should_receive(:new).with(arguments).and_return mock_model(Period)
        get :new , {:organism_id=>@o.id} , valid_session
        assigns[:end_year].should == (Date.today.year + 3)
      end
    end

  end
end

