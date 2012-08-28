# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PeriodsController do
   include SpecControllerHelper 

   before(:each) do
     minimal_instances
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

